{ config, ... }:

{

imports = [ ./base.nix ];
networking.hostName = "gaivota";

# eduroam FCUP was not working - hopefully this fixes it:
# HARICA TLS ECC Root CA 2021, CROSS-SIGNED by HARICA ECC RootCA 2015.
# This is the exact trust anchor eduroam's radius.up.pt (FCUP / U.Porto) presents
# at depth 2 (SHA-256 50e27f90...1636ae1). Mozilla/NSS ships only the *self-signed*
# HARICA TLS ECC Root CA 2021 (a DIFFERENT cert, 3f99cc47...), so the system CA
# store alone cannot validate the U.Porto chain.
# Source: https://repo.harica.gr/certs/HARICA-TLS-Root-2021-ECC-cross.der
security.pki.certificates = [
''
-----BEGIN CERTIFICATE-----
MIIDezCCAwGgAwIBAgIQcWAnyIV6c1Qt71FsHC7rDzAKBggqhkjOPQQDAzCBqjEL
MAkGA1UEBhMCR1IxDzANBgNVBAcTBkF0aGVuczFEMEIGA1UEChM7SGVsbGVuaWMg
QWNhZGVtaWMgYW5kIFJlc2VhcmNoIEluc3RpdHV0aW9ucyBDZXJ0LiBBdXRob3Jp
dHkxRDBCBgNVBAMTO0hlbGxlbmljIEFjYWRlbWljIGFuZCBSZXNlYXJjaCBJbnN0
aXR1dGlvbnMgRUNDIFJvb3RDQSAyMDE1MB4XDTIxMDkwMjA3NDQzN1oXDTI5MDgz
MTA3NDQzNlowbDELMAkGA1UEBhMCR1IxNzA1BgNVBAoMLkhlbGxlbmljIEFjYWRl
bWljIGFuZCBSZXNlYXJjaCBJbnN0aXR1dGlvbnMgQ0ExJDAiBgNVBAMMG0hBUklD
QSBUTFMgRUNDIFJvb3QgQ0EgMjAyMTB2MBAGByqGSM49AgEGBSuBBAAiA2IABDgI
/rGgltJ6rK9JOtDA4MM7KKrxcm1lAEeIhPyaJmuqS7psBAqIXhfyVYf8MLA04jRY
VxqEU+kw2anylnTDUR9YSTHMmE5gEYd103KUkE+bECUqqHgtvpBBWJAVcqeht6OC
AScwggEjMA8GA1UdEwEB/wQFMAMBAf8wHwYDVR0jBBgwFoAUtCILgpkkAQ6cu+QO
/b/7lyCTmSowTwYIKwYBBQUHAQEEQzBBMD8GCCsGAQUFBzAChjNodHRwOi8vcmVw
by5oYXJpY2EuZ3IvY2VydHMvSGFyaWNhRUNDUm9vdENBMjAxNS5jcnQwEQYDVR0g
BAowCDAGBgRVHSAAMB0GA1UdJQQWMBQGCCsGAQUFBwMCBggrBgEFBQcDATA9BgNV
HR8ENjA0MDKgMKAuhixodHRwOi8vY3JsLmhhcmljYS5nci9IYXJpY2FFQ0NSb290
Q0EyMDE1LmNybDAdBgNVHQ4EFgQUyRtTgRL+BNUW0aq8mm+3oJUZbsowDgYDVR0P
AQH/BAQDAgGGMAoGCCqGSM49BAMDA2gAMGUCMQCPc45gQV6pCkMR4px3k+YnF0Mo
DpXQ0+0lWz7fnplqgHn+qHmoKrE5Y/bcWucG6QQCMB/DIYjUTGAl5j07G7ZIuK3Q
ehx68VPXTwvJ9tLbh9A9SkiBmJGpiHL7Rzfxa5CptQ==
-----END CERTIFICATE-----
''
];

programs.steam.enable = true;

services.xserver.videoDrivers = [ "nvidia" ];
hardware.nvidia = {
  open = false;
  modesetting.enable = true;
  package = config.boot.kernelPackages.nvidiaPackages.legacy_580;
};
hardware.graphics.enable = true;

}
