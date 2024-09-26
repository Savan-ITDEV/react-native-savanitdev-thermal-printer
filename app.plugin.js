const { withAndroidManifest } = require("@expo/config-plugins");
const fs_1 = require("fs");
const path_1 = require("path");
// add this code for auto add in manifest android
module.exports = function androiManifestPlugin(config) {
  return withAndroidManifest(config, async (config) => {
    let androidManifest = config.modResults.manifest;
    androidManifest["uses-feature"] = {
      $: {
        "android:name": "android.hardware.usb.host",
        "android:required": "false",
      },
    };
    androidManifest.application[0].activity[0]["meta-data"] = [
      {
        $: {
          "android:name": "android.hardware.usb.action.USB_DEVICE_ATTACHED",
          "android:resource": "@xml/device_filter",
        },
      },
      {
        $: {
          "android:name": "android.hardware.usb.action.USB_ACCESSORY_ATTACHED",
          "android:resource": "@xml/accessory_filter",
        },
      },
    ];

    androidManifest.application[0]["service"] = {
      $: {
        "android:name": "net.posprinter.service.PosprinterService",
      },
    };
    androidManifest.application[0].activity[0]["intent-filter"][0].action[1] = {
      $: {
        "android:name": "android.hardware.usb.action.USB_DEVICE_ATTACHED",
      },
    };
    const projectRoot = config.modRequest.projectRoot;
    const soundFileRelativePath = "./assets/sounds/bells.wav";
    try {
      const destinationFilepath = `${projectRoot}/android/app/src/main/res/xml/device_filter.xml`;
      const sourceFilepath = `${projectRoot}/assets/xml/device_filter.xml`;
      const rawResourcesPath = `${projectRoot}/android/app/src/main/res/xml`;
      if (!(0, fs_1.existsSync)(rawResourcesPath)) {
        (0, fs_1.mkdirSync)(rawResourcesPath, { recursive: true });
      }
      (0, fs_1.copyFileSync)(sourceFilepath, destinationFilepath);

      const destinationFilepath2 = `${projectRoot}/android/app/src/main/res/xml/accessory_filter.xml`;
      const sourceFilepath2 = `${projectRoot}/assets/xml/accessory_filter.xml`;
      const rawResourcesPath2 = `${projectRoot}/android/app/src/main/res/xml`;
      if (!(0, fs_1.existsSync)(rawResourcesPath2)) {
        (0, fs_1.mkdirSync)(rawResourcesPath2, { recursive: true });
      }
      (0, fs_1.copyFileSync)(sourceFilepath2, destinationFilepath2);
    } catch (e) {
      throw new Error(
        ERROR_MSG_PREFIX +
          "Encountered an issue copying Android notification sounds: " +
          e
      );
    }
    // }

    return config;
  });
};
