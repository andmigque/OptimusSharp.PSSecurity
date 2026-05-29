 # Elevated.Tests
 > Pester integration tests for the admin-gated Windows surface. The whole file skips unless the
 > host shell is elevated, so an unattended run reports these as skipped rather than failed.

 Each block captures and restores the global state it mutates. The sacrificial local-admin user is
 named `_OptimusSecurityTest_<random>` and removed in AfterAll.
