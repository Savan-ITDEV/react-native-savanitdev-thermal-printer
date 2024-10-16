# react-native-savanitdev-thermal-printer

## Support

| Expo | ✅  
| React Native CLI | ✅
| Flutter | ✅

| Implement      | Android | IOS     |
| -------------- | ------- | ------- |
| Base64         | ✅      | ✅      |
| Label          | contact | contact |
| multiple print | contact | contact |
| XPrinter       | ✅      | ✅      |
| ZyWell         | ✅      | ✅      |

## Support

| Printer    | Android | IOS         |
| ---------- | ------- | ----------- |
| BLEPrinter | ✅      | ✅          |
| NetPrinter | ✅      | ✅          |
| USB        | ✅      | coming soon |

<br />
<div style="display: flex; flex-direction: row; align-self: center; align-items: center">
<img src="https://i.ibb.co/30j9w2H/img1.jpg" alt="bill" width="370" height="400"/>
<img src="https://i.ibb.co/5Kr2JD4/img2.jpg" alt="screenshot" width="370" height="420"/>
</div>

[Link download APK for test](https://drive.google.com/file/d/19-ms581VjLyIBO7y7JSaQ-bL3TtqS46b/view?usp=sharing)

## Video example test multiple printing

[Watch the video on YouTube test multiple printing](https://youtu.be/hyEmWCuuu-g?si=ZGrFVPcgChBbS6Kx)

- video link support print WIFI,BTE and USB in one time
-

## Installation

```
npm i react-native-savanitdev-thermal-printer

```

or

```
yarn add react-native-savanitdev-thermal-printer

```

## Example

**`Print Columns Text`**

```
npm i esc-pos-encoder-savanitdev

```

```tsx
import EscPosEncoder from "esc-pos-encoder-savanitdev";
import { Buffer } from "buffer";

useEffect(() => {
  if (Platform.OS === "android") {
    onCreate();
  }
}, []);

const printRaw = () => {
  let encoder = new EscPosEncoder();
  let result = encoder
    .table(
      [
        { width: 36, marginRight: 2, align: "left" },
        { width: 10, align: "right" },
      ],
      [
        ["Item 1", "€ 10,00"],
        ["Item 2", "15,00"],
        ["Item 3", "9,95"],
        ["Item 4", "4,75"],
        ["Item 5", "211,05"],
        ["", "=".repeat(10)],
        ["Total", (encoder) => encoder.bold().text("€ 250,75").bold()],
      ]
    )
    .encode();
  const base64string = Buffer.from(result).toString("base64");
  printRawData(base64string, "your ip printer");
};
```

**`Print image`**

```tsx
const printImg = () => {
  if (Platform.OS === "android") {
    // for IOS if you got error when print image please check your size of your image it's just limit 10-20mb
    printImgNet("192.168.1.xxx", "your image base64string");
  } else {
    // for android
    printImgNet("192.168.1.xxx", "your image base64string", 576, 576);
  }
};
```

**`Print Loop different IP printer`**

```tsx
// example for IOS
const printLoop = () => {
  for (let i = 0; i < ListIPPrinter.length; i++) {
    const res = ListIPPrinter[i];
    connectNet(res.ip)
      .then((e: any) => {
        printTest(res.ip);
      })
      .catch((err: any) => {
        // do something
      });
  }
};

// example for android
const printLoop = () => {
  for (let i = 0; i < ListIPPrinter.length; i++) {
    const res = ListIPPrinter[i];
    await new Promise((resolve) => {
      connectNet(res.ip_address)
        .then((e) => {
          setTimeout(() => {
            printImgBase64(base64, 576, 576)
              .finally(() => {
                disConnect(res.ip_address);
                setTimeout(resolve, 500);
              })
              .catch((e) => {
                console.log("error print =>", e);
              });
          }, 500);
        })
        .catch((err) => {
          setTimeout(resolve, 0);
        });
    });
  }
};
```

## Support Me by give Star ⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️⭐️

<img alt="Star the SavanitDev repo on GitHub to support the project" src="https://user-images.githubusercontent.com/9664363/185428788-d762fd5d-97b3-4f59-8db7-f72405be9677.gif" width="50%">

## FAQ Support 🔰🔰🔰

you can contact me directly [Telegram](@dev_la), feedback your problem

<img src="https://i.ibb.co/vc8HjFW/dev-la.jpg">

or ✉️

Telegram : @dev_la
Fanpage : https://www.facebook.com/SavanitDev

Thank you guys
