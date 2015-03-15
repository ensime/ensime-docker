Docker images for building/testing ENSIME.

In ENSIME we have an official JDK version for the build (Wheezy's
openjdk6), but may wish to test across various common releases.

We also have branches for the major Scala versions and the Emacs
client can be on any of the 24.x releases. That gives a matrix of
about 80 cells.

Instead of trying to be "clever" about Docker image inheritance, we
have a monolithic image for each major ENSIME release.
