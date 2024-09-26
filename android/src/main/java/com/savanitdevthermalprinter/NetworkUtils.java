package com.savanitdevthermalprinter;

import android.util.Log;

import com.facebook.react.bridge.Promise;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.InetAddress;
import java.net.InetSocketAddress;
import java.net.Socket;

public class NetworkUtils {

    // Ping IP address with custom parameters for fast ping and get the average RTT
    public static void fastPingAndGetNetworkSpeed(String ipAddress, int timeout, Promise promise) {
        try (Socket socket = new Socket()) {
            long startTime = System.currentTimeMillis();

            // Attempt to connect to the remote host on the specified port
            socket.connect(new InetSocketAddress(ipAddress, 9100), timeout);

            long endTime = System.currentTimeMillis();
            long timeTaken = endTime - startTime;

            System.out.println("Ping successful, time taken: " + timeTaken + " ms");
            promise.resolve(String.valueOf(timeTaken));
        } catch (IOException e) {
            System.out.println("Ping failed: " + e.getMessage());
            promise.reject("ERROR", "Ping fail please check your device");
        }

    }

    // Parse the output of the ping command to get the network speed (RTT)
    private static void parsePingOutputForSpeed(String pingOutput, Promise promise) {
        String[] lines = pingOutput.split("\n");
        for (String line : lines) {
            // Find the line that contains "avg" for average RTT
            if (line.contains("avg")) {
                String[] parts = line.split("/");
                if (parts.length >= 5) {
                    // Get the average round-trip time (RTT) in ms
                    Log.d("ping device ========> ", "Average RTT: " + parts[4] + " ms");
                    promise.resolve(parts[4]);
                }
            }
        }
        promise.reject("ERROR", "Ping fail please check your device");
    }
}