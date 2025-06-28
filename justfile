build-lambdas:
    #!/bin/bash
    cd lambda/corr
    rm -rf pkg.zip pkg
    mkdir pkg
    pip install --platform manylinux2014_x86_64 --target=pkg --implementation cp --python-version 3.11 --only-binary=:all: --upgrade -r requirements.in
    cd pkg
    zip -r ../pkg.zip .
    cd ../
    zip pkg.zip handler.py

    cd ../stat
    rm -rf pkg.zip pkg
    mkdir pkg
    pip install --platform manylinux2014_x86_64 --target=pkg --implementation cp --python-version 3.11 --only-binary=:all: --upgrade -r requirements.in
    cd pkg
    zip -r ../pkg.zip .
    cd ../
    zip pkg.zip handler.py

    cd ../report
    rm -rf pkg.zip pkg
    mkdir pkg
    pip install --platform manylinux2014_x86_64 --target=pkg --implementation cp --python-version 3.11 --only-binary=:all: --upgrade -r requirements.in
    cd pkg
    zip -r ../pkg.zip .
    cd ../
    zip pkg.zip handler.py  