# Facebook Login - WEB Example

This projetc is a demo. Use it to test flutter web with facebook login plugin.
- [Demo online](https://fb-login-29c92.firebaseapp.com)

## Getting Started

Open and replace your appId created in Facebook dashboard.
- example02/web/index.html
- example02/ios/Runner/Info.plist
- example02/android/app/src/main/res/values/strings.xml

<b>Obs.</b> Run this project using <b>https connection</b>.

## Https in localhost

Using <b>Linux</b> or <b>Mac</b>, run:
```
$ ./https_runner.sh
```

<b>Obs1.</b> First time, the script will check if you have a valid https certificate. If not, it will be created. Follow the questions.

<b>Obs2.</b>Second time the script will build flutter web and run a python server inside the project folder.

<b>Obs3.</b>After build process you will see a link. Open this link in your broswer.
```
open https://localhost:4443/build/web
```

<b>Obs4.</b> Every time code changes, you will need run this command again.