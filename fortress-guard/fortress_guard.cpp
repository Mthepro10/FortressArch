#include <iostream>
#include <string>
#include <vector>
#include <unistd.h>
#include <cstring>
#include <cerrno>

const std::vector<std::string> DANGEROUS_PREFIXES = {
    "rm -rf",
    "dd if=",
    "mkfs",
    "fdisk",
    "parted",
    "shutdown",
    "reboot",
    "systemctl poweroff",
    ":(){ :|:& };:"
};

bool isRunningAsRoot() {
    return geteuid() == 0;
}

bool isDangerousCommand(const std::string& command) {
    for (const auto& prefix : DANGEROUS_PREFIXES) {
        if (command.find(prefix) != std::string::npos) {
            return true;
        }
    }
    return false;
}

std::vector<char*> toExecArgs(const std::vector<std::string>& args) {
    std::vector<char*> execArgs;
    for (auto& a : args) {
        execArgs.push_back(const_cast<char*>(a.c_str()));
    }
    execArgs.push_back(nullptr);
    return execArgs;
}

int runDirect(const std::vector<std::string>& args) {
    auto execArgs = toExecArgs(args);
    execvp(execArgs[0], execArgs.data());
    std::cerr << "Failed to execute command: " << strerror(errno) << std::endl;
    return 1;
}

int runSandboxed(const std::vector<std::string>& args) {
    std::vector<std::string> bwrapArgs = {
        "bwrap",
        "--ro-bind", "/usr", "/usr",
        "--ro-bind", "/etc", "/etc",
        "--proc", "/proc",
        "--dev", "/dev",
        "--tmpfs", "/tmp",
        "--unshare-net",
        "--die-with-parent",
        "--"
    };
    for (auto& a : args) {
        bwrapArgs.push_back(a);
    }

    auto execArgs = toExecArgs(bwrapArgs);
    execvp("bwrap", execArgs.data());
    std::cerr << "Failed to launch bubblewrap sandbox: " << strerror(errno) << std::endl;
    return 1;
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::cerr << "Usage: fortress-guard <command> [arguments...]" << std::endl;
        return 1;
    }

    std::vector<std::string> args(argv + 1, argv + argc);

    std::string fullCommand;
    for (auto& a : args) {
        fullCommand += a + " ";
    }

    bool asRoot = isRunningAsRoot();
    bool dangerous = isDangerousCommand(fullCommand);

    if (dangerous && !asRoot) {
        std::cout << "[fortress-guard] Dangerous command detected. Running sandboxed." << std::endl;
        return runSandboxed(args);
    }

    return runDirect(args);
}
