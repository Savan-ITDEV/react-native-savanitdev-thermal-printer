import {
  Alert,
  NativeModules,
  PermissionsAndroid,
  Platform,
} from "react-native";

import { Buffer } from "buffer";

const LINKING_ERROR =
  `The package 'react-native-savanitdev-thermal-printer' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: "" }) +
  "- You rebuilt the app after installing the package\n" +
  "- You are not using Expo Go\n";

const SavanitdevThermalPrinter = NativeModules.SavanitdevThermalPrinter
  ? NativeModules.SavanitdevThermalPrinter
  : new Proxy(
    {},
    {
      get() {
        throw new Error(LINKING_ERROR);
      },
    }
  );

export function pingPinter(ip: string): Promise<boolean> {
  return SavanitdevThermalPrinter.pingPinter(ip);
}
export function onCreate() {
  if (Platform.OS === "android") {
    handleAndroidPermissions();
    return SavanitdevThermalPrinter.onCreate();
  }
}
export function connectNet(ip: string): Promise<boolean> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.connectNet(ip);
  } else {
    return SavanitdevThermalPrinter.connectNet(ip);
  }
}

export function getUSB(): Promise<String> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.getUSB();
  } else {
    return SavanitdevThermalPrinter.getUSB();
  }
}
export function connectUSB(usbAddress: string): Promise<boolean> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.connectUSB(usbAddress);
  } else {
    return SavanitdevThermalPrinter.connectUSB(usbAddress);
  }
}
export function printImg(
  img: string,
  w1: number,
  w2: number,
  isCut: number
): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.printImg(img, w1, w2, isCut);
  }
}

export function printTest(ip: string): Promise<string> {
  if (Platform.OS === "ios") {
    return SavanitdevThermalPrinter.printTest(ip);
  }
}
export async function printImgNet(
  ip: string,
  img: string,
  w1: number,
  w2: number,
  isDisconnect = true
): Promise<string> {
  if (Platform.OS === "android") {
    return await SavanitdevThermalPrinter.printImg(img, w1, w2, 0);
  } else {
    return SavanitdevThermalPrinter.printImgNet(ip, img, isDisconnect);
  }
}
export async function printImgNetSticker(
  ip: string,
  img: string,
  w1: number,
  w2: number,
): Promise<string> {
  if (Platform.OS === "android") {
    return await SavanitdevThermalPrinter.printImg(img, w1, w2, 1);
  } else {
    return SavanitdevThermalPrinter.printImgNetSticker(ip, img, false);
  }
}

export const handleAndroidPermissions = () => {
  try {
    if (Platform.OS === "android" && Platform.Version >= 31) {
      PermissionsAndroid.requestMultiple([
        PermissionsAndroid.PERMISSIONS.BLUETOOTH_SCAN,
        PermissionsAndroid.PERMISSIONS.BLUETOOTH_CONNECT,
      ]).then((result: any) => {
        if (result) {
          // console.debug(
          //   "[handleAndroidPermissions] User accepts runtime permissions android 12+"
          // );
        } else {
          console.error(
            "[handleAndroidPermissions] User refuses runtime permissions android 12+"
          );
        }
      });
    } else if (Platform.OS === "android" && Platform.Version >= 23) {
      PermissionsAndroid.check(
        PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION
      ).then((checkResult: any) => {
        if (checkResult) {
          // console.debug(
          //   "[handleAndroidPermissions] runtime permission Android <12 already OK"
          // );
        } else {
          PermissionsAndroid.request(
            PermissionsAndroid.PERMISSIONS.ACCESS_FINE_LOCATION
          ).then((requestResult: any) => {
            if (requestResult) {
              // console.debug(
              //   "[handleAndroidPermissions] User accepts runtime permission android <12"
              // );
            } else {
              console.error(
                "[handleAndroidPermissions] User refuses runtime permission android <12"
              );
            }
          });
        }
      });
    }
  } catch (error) {
    console.log("error ", error);
  }
};
export function printBitmap(
  img: string,
  w1: number,
  w2: number
): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.printBitmap(img, w1, w2);
  }
}

export async function disConnect(ip: string): Promise<string> {
  if (Platform.OS === "android") {
    return await SavanitdevThermalPrinter.disConnectNet();
  } else {
    // IP just required for IOS
    return await SavanitdevThermalPrinter.disconnectNet(ip);
  }
}
export function findAvailableDevice() {
  if (Platform.OS === "android") {
    const arr = [];
    return SavanitdevThermalPrinter.findAvailableDevice().then(
      (bluetoothDevices: {
        [x: string]: any;
        hasOwnProperty: (arg0: string) => any;
      }) => {
        for (const deviceName in bluetoothDevices) {
          if (bluetoothDevices.hasOwnProperty(deviceName)) {
            const deviceAddress: string = bluetoothDevices[deviceName];
            const body = {
              name: deviceAddress.split(",")[0],
              deviceAddress: deviceAddress.split(",")[1],
            };
            arr.push(body);
          }
        }
        // console.log("Lists device found : ", arr);
        return arr;
      }
    );
  }
}
export function printText(): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.printText();
  }
}
export function printRawData(
  encode: string,
  ip: string,
  isDisconnect = true
): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.printRawData(encode);
  } else {
    // IP must required for IOS
    return SavanitdevThermalPrinter.printEncodeNet(ip, encode, isDisconnect);
  }
}

export function clearLoops(ip: string): Promise<boolean> {
  if (Platform.OS === "android") {
  } else {
    return SavanitdevThermalPrinter.clearLoops();
  }
}

// BLEUTOOTH //

export function connectBT(macAddress: string): Promise<string> {
  try {
    if (Platform.OS === "android") {
      return SavanitdevThermalPrinter.connectBT(macAddress);
    } else {
      return SavanitdevThermalPrinter.connectBLE(macAddress);
    }
  } catch (error) {
    return "";
  }
}
export function checkStatusBLE(): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.checkStatusBLE();
  } else {
    return SavanitdevThermalPrinter.checkStatusBLE("");
  }
}
export function disconnectBLE(): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.disConnectBT();
  } else {
    return SavanitdevThermalPrinter.disconnectBLE("");
  }
}

export function printLangPrinter(): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.printLangPrinter();
  } else {
    return SavanitdevThermalPrinter.printLangPrinter();
  }
}
export function setLang(codepage = "70"): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.setLang(codepage);
  } else {
    return SavanitdevThermalPrinter.setLang(codepage);
  }
}
export function getLangModel(): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.getLangModel();
  } else {
    return SavanitdevThermalPrinter.getLangModel();
  }
}
export function cancelChinese(): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.cancelChinese();
  } else {
    return SavanitdevThermalPrinter.cancelChinese();
  }
}
export function initialBLE(): Promise<string> {
  if (Platform.OS === "android") {
    handleAndroidPermissions();
    return SavanitdevThermalPrinter.onCreate();
  } else {
    return SavanitdevThermalPrinter.initBLE();
  }
}
export function requestUSBPermission(): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.tryGetUsbPermission();
  } else {
  }
}

export function getByteArrayList(): Promise<Object> {
  return SavanitdevThermalPrinter.getByteArrayList()
    .then((base64Strings: []) => {
      const byteArrayList = base64Strings.map(
        (base64) => Buffer.from(base64, "base64").toJSON().data
      );
      const combined = byteArrayList.flat();
      return combined;
    })
    .catch((error) => {
      console.error("error", error);
    });
}
export async function getListDevice(): Promise<any[]> {
  if (Platform.OS === "android") {
  } else {
    return await SavanitdevThermalPrinter.getListDevice("");
  }
}

export async function startScanBLE(): Promise<any[]> {
  if (Platform.OS === "android") {
    return findAvailableDevice();
  } else {
    try {
      const arr = [];
      SavanitdevThermalPrinter.startScanBLE();
      return new Promise<any[]>(async (resolve, reject) => {
        getListDevice()
          .then((data) => {
            const body = data.map((i, k) => ({
              name: `${i.name}-${k}`,
              deviceAddress: i.identifier,
            }));
            resolve(body);
          })
          .catch((err) => {
            reject([]);
          });
      });
    } catch (error) {
      return [];
    }
  }
}
export function rawDataBLE(base64String: string): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.printRawData(base64String);
  } else {
    return SavanitdevThermalPrinter.rawDataBLE(base64String);
  }
}
export function image64BaseBLE(
  base64String: string,
  w1: number,
  w2: number,
  isCut: number
): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.printBitmapBLE(base64String, w1, w2, isCut);
  } else {
    return SavanitdevThermalPrinter.image64BaseBLE(base64String);
  }
}
// BLEUTOOTH //

export const printPOS = {
  printText: async function (): Promise<string> {
    return SavanitdevThermalPrinter.printText();
  },
  printTemplate: async function (
    ip: string,
    isDisconnect = true
  ): Promise<string> {
    if (Platform.OS === "ios") {
      return SavanitdevThermalPrinter.printTemplate(ip, isDisconnect);
    } else {
      printPOS.printText();
    }
  },
  initializeText: function () {
    return SavanitdevThermalPrinter.initializeText();
  },
  cut: function () {
    return SavanitdevThermalPrinter.cut();
  },
  clearPaper: function (): Promise<boolean> {
    return SavanitdevThermalPrinter.clearPaper();
  },
  printAndFeedLine: function () {
    return SavanitdevThermalPrinter.printAndFeedLine();
  },
  CancelChineseCharModel: function () {
    return SavanitdevThermalPrinter.CancelChineseCharModel();
  },
  selectAlignment: function selectAlignment(
    align: string = "center" || "left" || "right"
  ) {
    let num = 1;
    if (align === "center") {
      num = 1;
    }
    if (align === "right") {
      num = 2;
    }
    if (align === "left") {
      num = 0;
    }
    return SavanitdevThermalPrinter.selectAlignment(num);
  },

  text: function (text: string, charset = "cp874") {
    return SavanitdevThermalPrinter.text(text, charset);
  },
  setImg: function (base64String: string, w1: number) {
    return SavanitdevThermalPrinter.setImg(base64String, w1);
  },
  selectCharacterSize: function (size: number) {
    return SavanitdevThermalPrinter.selectCharacterSize(size);
  },
  line: function (size: number) {
    return SavanitdevThermalPrinter.line(size);
  },
  line2: function (size: number) {
    return SavanitdevThermalPrinter.line2(size);
  },
  line3: function (size: number) {
    return SavanitdevThermalPrinter.line3(size);
  },
  selectOrCancelBoldModel: function (size: number) {
    return SavanitdevThermalPrinter.selectOrCancelBoldModel(size);
  },
  selectCharacterCodePage: function (hex: number) {
    return SavanitdevThermalPrinter.selectCharacterCodePage(hex);
  },
  selectInternationalCharacterSets: function (hex: number) {
    return SavanitdevThermalPrinter.selectInternationalCharacterSets(hex);
  },
  setAbsolutePrintPosition: function (n: number, m: number) {
    return SavanitdevThermalPrinter.setAbsolutePrintPosition(n, m);
  },
  setEncode: function (encode: string) {
    return SavanitdevThermalPrinter.getEncode(encode);
  },
};
