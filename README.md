# cloud-resources-operator-product-build

This repository contains configuration required by Konflux for building and releasing Cloud Resource Operator.

## To release a new version

TODO: container image + bundle release

### Index image build and release

- Retrieve the bundle that was released
- Update the `cro-fbc/catalog-template.json` list with the name of the operator.version and replaces value:

```
                    "name": "cloud-resources.v1.1.4",
                    "replaces": "cloud-resources.v1.1.3"
```
- Update the `cro-fbc/catalog-template.json` list with the schema and image values:
```
        {
            "schema": "olm.bundle",
            "image": "<Released bundle>"
        }
```
- Run the following command from the project root `opm alpha render-template basic cro-fbc/catalog-template.json > cro-fbc/catalog/rhmi-cloud-resources/catalog.json` (command can take up to few minutes)
- Commit the changes and open a new PR against this repo. After successful validation of the PR proceed to release part of cro-fbc