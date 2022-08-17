# Logging
`Hopper.log` is simple function taking a string which can be used for debugging or logging various significant events encountered by your application. The logs are written to the log file configured in WAGI (a temporary file by default). This function is really no more than a wrapper around writing to `stderr`, the stream that WAGI uses for logging.

⚠️ _**️ Please note that you should NOT write to `stdout` for logging e.g. through Grain's built-in `print` function. WAGI reserves `stdout` for writing HTTP responses!**_ ⚠️
