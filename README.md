# Samsung Smart AC Remote Control Ruby Library

This project was forked from an [unmantained repository](https://bitbucket.org/CloCkWeRX/samsung-remote/)

## Getting Started

### Install dependencies

#### Fedora 28
```
# dnf install rubygem-nokogiri rubygem-mechanize
```

### Extract client certifcate
In order to use the library you need to extract the client certificate from the original
App. Please follow the [dedicated howto](doc/extractClientCertificate.md).

### Get a Authorization token
The Samsung Air conditioners use a strange access token mechanism.
Follow the [guide](doc/getAccessToken.md) for getting one.

### Examples
See example-remote.rb.
