# ci-al-go

Amazon linux go environment for use by CI.

This is an updated version of criticalblue/amazonlinux-go but now in a new repo
so we can start using proper tags of the repo and docker images without
impacting existing CI flows. With a proper tagging strategy we can use
different versions of this project from different branches of dependent
projects without impacting unrelated CI builds.
