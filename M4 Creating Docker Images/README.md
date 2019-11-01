### Module 4 Demo Files

This folder contains the following Dockerfiles for the `SampleWebApp` ASP.NET Core application:

- `basic.Dockerfile` - The simplest possible Dockerfile that assumes you've already built the application locally to the `out` folder
- `multi-stage.Dockerfile` - This Dockerfile builds the ASP.NET Core application within a Docker container and then creates a Docker image to run the application.
- `Dockerfile` - same as `multi-stage.Dockerfile`
- `win.Dockerfile` - The equivalent of the basic Dockerfile, but explicitly targeting Windows

It contains the following PowerShell scripts. These are not intended to be run as entire scripts, but to run them you should execute the commands one by one.

- `m4-01-build-dockerfile.ps1` - shows the commands used in the Pluralsight course to build using the `basic.Dockerfile`
- `m4-02-build-dockerfile-v2,ps1` - shows the commands used in the Pluralsight course to build using `multi-stage.Dockerfile`
- `m4-03-azure-container-registry.ps1` - shows the commands used in the Pluralsight course to create an Azure Container Registry and upload a Docker image to it.

### Running the examples.

To run these examples you should be in the `SampleWebApp` folder, which contains the source code for the ASP.NET Core application (and copies of these Dockerfiles).