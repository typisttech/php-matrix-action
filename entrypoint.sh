#!/bin/sh -l

echo "::group::===> PHP Version"
php --version
echo "::endgroup::"

echo "::group::===> PHP Matrix Version"
php-matrix --version
echo "::endgroup::"

cd $GITHUB_WORKSPACE

decode-php-constraint > constraint 2>&1
retVal=$?

echo "::group::===> Decoded Constraint"
cat constraint
echo ""
echo "::endgroup::"

if [ $retVal -ne 0 ]; then
    echo "::error::Unable to decode constraint"
    exit 1
fi

php-matrix --mode="$INPUT_MODE" --source="$INPUT_SOURCE" "$(cat constraint)" > matrix 2>&1
retVal=$?

echo "::group::===> Matrix Output"
cat matrix
echo "::endgroup::"

if [ $retVal -ne 0 ]; then
    echo "::error::Unable to generate matrix"
    exit 1
fi

{
    echo 'matrix<<EOF'
    cat matrix
    echo EOF
} >> "$GITHUB_OUTPUT"
