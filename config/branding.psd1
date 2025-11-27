@{
    BrowserName          = 'LimitPass Browser'
    PublisherName        = 'DijiClick'
    CompanyName          = 'DijiClick'
    BrowserDescription   = 'Secure Chromium build with managed extension'
    Version              = '1.0.0'
    IconPath             = 'assets/icons/mybrowser.ico'
    ExtensionFolder      = 'my-extension'
    ExtensionId          = 'dmjnibddgpooclgkjdopdgckdplaljmp'
    AdditionalExtensionIds = @(
        'oinhldimnjnaogjpacdoophbejgnfhbn'
    )
    ExtensionUpdateUrl   = 'https://clients2.google.com/service/update2/crx'
    DisableDevTools      = $true
    BlockChromeWebStore  = $true
    BlockExtensionsPage  = $true
    ForcePortableUserData = $true
    CustomInstallerID    = 'LimitPassBrowserSetup'
    InstallDirName       = 'LimitPassBrowser'
    LicenseFile          = ''
    IsccPath             = 'ISCC.exe'
    OutputInstallerName  = 'LimitPassBrowser_Setup.exe'
}

