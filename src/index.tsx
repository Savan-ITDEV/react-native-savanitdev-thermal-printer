import {
  NativeModules,
  Platform,
  PermissionsAndroid,
  Alert,
} from "react-native";

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
export function printImg(img: string, w1: number, w2: number): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.printImg(img, w1, w2);
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
  w2: number
) {
  if (Platform.OS === "android") {
    return await SavanitdevThermalPrinter.connectNetImg(ip, img, w1, w2);
  } else {
    return await SavanitdevThermalPrinter.printImgNet(ip, img);
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

export function printBitmapBLE(
  img: string,
  w1: number,
  w2: number,
  isBLE: number
): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.printBitmapBLE(img, w1, w2, isBLE);
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
    return SavanitdevThermalPrinter.findAvailableDevice()
      .then(
        (bluetoothDevices: {
          [x: string]: any;
          hasOwnProperty: (arg0: string) => any;
        }) => {
          for (const deviceName in bluetoothDevices) {
            if (bluetoothDevices.hasOwnProperty(deviceName)) {
              const deviceAddress = bluetoothDevices[deviceName];
              arr.push({ name: deviceName, deviceAddress: deviceAddress });
              // console.log(
              //   `Device Name: ${deviceName}, Device Address: ${deviceAddress}`
              // );
              // Do something with the deviceName and deviceAddress
            }
          }
          // console.log("Lists device found : ", arr);
          return arr;
        }
      )
      .catch(async (e: any) => {
        const result = await PermissionsAndroid.check(
          PermissionsAndroid.PERMISSIONS.BLUETOOTH_SCAN
        );
        console.error("error => ", e);

        if (result) {
          return [];
        } else {
          Alert.alert(
            "Warning!",
            "please allow permission bluetooth for your app!"
          );
          return [];
        }
      });
  }
}
export function printText(): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.printText();
  }
}
export function printRawData(encode: string, ip: string): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.printRawData(encode);
  } else {
    // IP must required for IOS
    return SavanitdevThermalPrinter.printEncodeNet(ip, encode);
  }
}
export function connectBT(macAddress: string): Promise<string> {
  if (Platform.OS === "android") {
    return SavanitdevThermalPrinter.connectBT(macAddress);
  }
}
export function clearLoops(ip: string): Promise<boolean> {
  if (Platform.OS === "android") {
  } else {
    return SavanitdevThermalPrinter.clearLoops();
  }
}

export const printPOS = {
  printText: function () {
    return SavanitdevThermalPrinter.printText();
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

  text: function (text: string, charset: string) {
    return SavanitdevThermalPrinter.text(text, charset);
  },
  selectCharacterSize: function (size: number) {
    return SavanitdevThermalPrinter.selectCharacterSize(size);
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
};
