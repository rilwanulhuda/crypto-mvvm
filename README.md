# About

This is a sample project.<br/>
I created a simple app using MVVM architecture.<br/>
I use Alamofire to handle api call and Starscream to handle websocket connection.
<br/><br/>
Author: Rilwanul Huda<br/>
Email: rilwanulhuda.dev@gmail.com

# Features
- Home : Displaying top list of cryptocurrencies.
- News : Displaying news based on selected cryptocurrency symbol.

# How To Run Unit Test

- Install Mockingbird framework in your project then go to the Mockingbird Folder.
```sh
cd Pods/MockingbirdFramework && sudo make install-prebuilt
```

- Go back to the project root directory, then download its starter pack.
```sh
cd ... && mockingbird download starter-pack
```

- Install mockingbird to test target.
```sh
mockingbird install --target CryptoTests --sources 'Crypto'
```

- Finally, generate mocks.
```sh
mockingbird generate --targets 'Crypto' --output 'MockingbirdMocks/CryptoTests-CryptoMocks.generated.swift' --disable-cache --verbose
```
