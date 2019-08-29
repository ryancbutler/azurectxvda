Checkout https://www.techdrabble.com/microsoft/azure/33-deploy-citrix-server-vda-on-azure-with-packer for how to.

## Can be Deployed with
1. [GitHub Actions](.github/workflows/buildVda.yml)
    - Requires secrets
    - Can use [KickOffJob.ps1](.github/workflows/KickOffJob.ps1) to run.  (Adjust script with user token)
2. [Jenkins](Jenkinsfile)
    - Requires Docker plugin
    - Requires secrets
3. [Azure Pipelines](azure-pipelines.yml)
    - Requires secrets
