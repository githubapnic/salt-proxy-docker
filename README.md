# docker-salt-3006

## Files and Dockerfile for building the salt user image for the Automation Labs

to build this docker image:

```
docker buildx build -t salt:MyTag .
```

You will then need to retag, to push where ever you need it.

This has been tested and the build as per this dockerfile(24/01/2025) Is in the training docker registry

**Enjoy!**
