# How to extract AC client certificate
Follow this how to in order to extract the cert.pm you need in order to use this library.

#### 1. Download the 'Smart Air Conditioner_com.samsung.rac.apk'.
You can either download it from the web or extract it by installing it on
your Android device and using a helper app like "APK Extractor".
 
#### 2. Extract the original KeyStore
simply execute
```
$ unzip 'Smart Air Conditioner_com.samsung.rac.apk' -d APK
```
You will find the original keystore under

```
$ ls -la APK/assets/AC14K_M_KeyStore.bks 
-rw-r--r--. 1 u238 u238 4855 May 17 18:37 APK/assets/AC14K_M_KeyStore.bks
```

#### 3. Convert it to PKCS12 format
If you java installation doesn't have the BouncyCastleProvider installed, download
the jar from the official [site](https://www.bouncycastle.org/latest_releases.html).
Then convert the KeyStore with keytool:
```
$ keytool -importkeystore -srckeystore AC14K_M_KeyStore.bks -srcstoretype BKS -destkeystore ac14k_m.pfx -deststoretype PKCS12 -srcalias ac14k_m -deststorepass password -destkeypass password -provider org.bouncycastle.jce.provider.BouncyCastleProvider -providerpath /path/to/bcprov-jdk15on-160.jar
```

#### 4. Convert it to PEM format
```
$ openssl pkcs12 -in ac14k_m.pfx -out cert.pem -nodes
```

You will now have a valid cert.pem to use with the library.

