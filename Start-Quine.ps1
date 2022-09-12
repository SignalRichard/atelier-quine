param(
    [string] $RecipeFilePath,
    [string] $ImageTag = 'latest'
)

function Test-DockerImage {
    param(
        [string] $ImageName
    )

    $Identifier = (ConvertFrom-Json -InputObject ((docker inspect $ImageName) -join [String]::Empty)).Id

    if($null -eq $Identifier) {
        docker pull $ImageName
    }
}

$ImageName = "thatdot/quine:$ImageTag"
Test-DockerImage -ImageName $ImageName

# mount the recipes directory (assuming the script is run from the repo root) as a volume inside of the container under the pat "recipes"
# this will allow recipes to be passed in using the relative path from the repo root and then Quine will be able to find them
# Quine docker image always looks for recipes starting from root of image (/)
docker run -p 8080:8080 -v "$(Join-Path -Path $PWD.Path -ChildPath 'recipes'):/recipes" $ImageName -r $RecipeFilePath
