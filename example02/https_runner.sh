FILE=localhost.pem
if [ -f "$FILE" ]; then
    echo "$FILE exist"
    echo "Flutter build web..."
    flutter build web
    echo "Running HTTPS server (enable your $FILE on google chrome.)"
    echo "open https://localhost:4443/build/web/"
    python3 https_server.py
else 
    echo "$FILE does not exist"
    echo "Creating $FILE."
    ./https_cert.sh
    echo "run: './https_runner.sh' again."
fi