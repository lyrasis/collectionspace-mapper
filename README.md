# Collectionspace::Mapper

In general tests are currently assuming `cspace-config-untangler` is set up and hash RecordMapper objects are requestable from it. 

To test without setting up `cspace-config-untangler`, uncoment the `puts` line in `spec/collectionspace/mapper/data_mapper_spec.rb` `works with json RecordMapper` test and run that test. 

This will use the anthro-collectionobject RecordMapper JSON file in `spec/fixtures/files` to produce collectionobject xml using the `anthro_co_1` data hash in `spec/helpers.rb`.

## What it does so far

- has `config.json` where you define multivalue delimiter, subgroup delimiter, and any job-specific field transforms or default values
- BEFORE MAPPING, validates that any required fields are present and populated in the data
- applies default and custom (in config.json) data transformations, including: converting authority and vocabulary terms into refnames; replacements; bherensmeyer number translation; downcasing values
- applies default field values specified in config.json if fields with default values are empty or nil in the data hash. Default field values do not overwrite actual data values from the data hash
- returns Nokogiri::XML::Document (without empty/blank nodes) with appropriate namespace defintions

## Still to do

- Testing more broadly with different profiles and recordtypes, since there are some annoying outlier/inconsistencies in some configs
- Refactor/redesign (I switched to "just make it work" rather than "what's the best way to design/organize this code" somewhere in the process. Advice welcome here)
- Startup to run `spec/collectionspace/mapper/data_mapper_spec.rb` is quite slow. Figure out if there's some repetitive/inefficient code causing the slowness, or if it's due to refcache lookups or something.
- Add post-mapping validation, including warnings about use of static option list values not in the option list (This needs to be done post-mapping because the data transformations are called in the mapping process)
- Add transformations: structured date and other date formats; boolean; upcase first character
- For authority record types, produce Short Identifier using first `termDisplayName` value (this will keep separate authorities from being added for non-preferred terms, I believe?)
- Figure out how we want to return errors (required field value missing) and warnings (uses values not in option list; uneven number of values across a repeating fieldgroup) to be available in Converter UI
- Figure out how to flag authority and vocabulary terms that don't already exist in the instance (and/or stub records for them) to be available for review/import via UI
- Probably more...
