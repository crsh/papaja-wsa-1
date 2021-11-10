#!/bin/sh

# PAPAJA_BASE is the name used for the base image that can be reused across
# projects to save disk space and get up and running more quickly
#
# PROJECT_NAME is the name used for the image of the current project (including
# project-specific R packages etc.)

PAPAJA_BASE="papaja"
PROJECT_NAME="papajaworkshop"

# Look up available R_RELEASE's at
# https://github.com/rocker-org/rocker-versioned2/tree/master/stacks
#
# PAPAJA_VERSION's are appended to the repostiory URL;
# see ?remotes::install_github
#
# For valid RSTUDIO_VERSION's refer to
# https://www.rstudio.com/products/rstudio/release-notes/
#
# Any year starting from 2000 is a valid TEXLIVE_VERSION

R_RELEASE="4.1.2"
PAPAJA_VERSION="@devel"
RSTUDIO_VERSION="2021.09.0+351"
TEXLIVE_VERSION="2021"

# NCPUS controls the number of cores to use to install R packages in parallel

NCPUS=1


# ------------------------------------------------------------------------------

TAG="$R_RELEASE-$(echo $PAPAJA_VERSION | grep -o "\w*$")-$(echo $RSTUDIO_VERSION | grep -o "^[0-9]*\.[0-9][0-9]")-$TEXLIVE_VERSION"
PAPAJA_BASE="papaja:$TAG"
PROJECT_NAME="$PROJECT_NAME:$TAG"

docker build \
    --build-arg R_RELEASE=$R_RELEASE \
    --build-arg RSTUDIO_VERSION=$RSTUDIO_VERSION \
    --build-arg TEXLIVE_VERSION=$TEXLIVE_VERSION \
    --build-arg PAPAJA_VERSION=$PAPAJA_VERSION \
    --build-arg NCPUS=$NCPUS \
    --target papaja \
    -t $PAPAJA_BASE .

docker build \
    --build-arg PAPAJA_BASE=$PAPAJA_BASE \
    --build-arg PROJECT_NAME=$PROJECT_NAME \
    --build-arg NCPUS=$NCPUS \
    --target project \
    -t $PROJECT_NAME .

# Add as needed to work with git inside the container
#
# Share global .gitconfig with container
#    -v ~/.gitconfig:/home/rstudio/.gitconfig:ro \
#
# Share SSH credentials with container
#    -v ~/.ssh:/home/rstudio/.ssh:ro \

docker run -d \
    -p 8787:8787 \
    -e DISABLE_AUTH=TRUE \
    -e ROOT=TRUE \
    -v "/$PWD":/home/rstudio \
    --name $(echo $PROJECT_NAME | grep -o "^[a-zA-Z0-9]*") \
    --rm \
    $PROJECT_NAME

sleep 1

git web--browse http://localhost:8787
