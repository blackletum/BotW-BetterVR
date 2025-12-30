HANDLE Log::consoleHandle = NULL;
double Log::timeFrequency = 0.0f;
std::ofstream Log::logFile;

Log::Log() {
    AllocConsole();
    SetConsoleTitleA("BetterVR Debugging Console");
    consoleHandle = GetStdHandle(STD_OUTPUT_HANDLE);
#ifdef _DEBUG
#else
    logFile.open("BetterVR.txt", std::ios::out | std::ios::trunc);
#endif
    Log::print<INFO>("Successfully started BetterVR!");
    LARGE_INTEGER timeLI;
    QueryPerformanceFrequency(&timeLI);
    timeFrequency = double(timeLI.QuadPart) / 1000.0;
}

Log::~Log() {
    Log::print<INFO>("Shutting down BetterVR debugging console...");
    FreeConsole();
#ifdef _DEBUG
#else
    if (logFile.is_open()) {
        logFile.close();
    }
#endif
}

void Log::printTimeElapsed(const char* message_prefix, LARGE_INTEGER time) {
    LARGE_INTEGER timeNow;
    QueryPerformanceCounter(&timeNow);
    Log::print<INFO>("{}: {} ms", message_prefix, double(time.QuadPart - timeNow.QuadPart) / timeFrequency);
}