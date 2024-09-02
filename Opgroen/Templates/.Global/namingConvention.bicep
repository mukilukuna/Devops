// The name of the team that will be responsible for the resource.
@maxLength(4)
param region string

// The environment that the resource is for. Accepted values are defined to ensure consistency.
@allowed([
  'dev'
  'test'
  'acc'
  'prod'
])
param environment string

param appName string

param workload string

param resourceType string

param customName string = ''

@maxLength(2)
param role string = ''

// An index number. This enables you to have some sort of versioning or to create redundancy
param index int = 1

// First, we create shorter versions of the function and the teamname. 
// This is used for resources with a limited length to the name.
// There is a risk to doing at this way, as results might be non-desirable.
// An alternative might be to have these values be a parameter
var workloadShort = length(workload) > 5 ? substring(workload, 0, 5) : workload
var appNameShort = length(appName) > 5 ? substring(appName, 0, 5) : appName

// We only need the first letter of the environment, so we substract it.
var environmentLetter = substring(environment, 0, 1)

// This line constructs the resource name. It uses [PH] for the resource type abbreviation.
// This part can be replaced in the final template
var name = '${resourceType}-${workload}-${appName}-${environmentLetter}-${region}-${padLeft(index, 2, '0')}'

// This line creates a short version for resources with a max name length of 24
var nameShort = '${resourceType}-${workloadShort}-${appNameShort}-${environmentLetter}-${region}-${padLeft(index, 2, '0')}'

// This line creates a short version for resources with a max name length of 24
var nameGlobal = '${resourceType}-${workloadShort}-${appNameShort}-${environmentLetter}-${region}'

// Storage accounts have specific limitations. The correct convention is created here
var nameNoHyphen = 'st${workload}${appNameShort}${environmentLetter}${region}${padLeft(index, 2, '0')}'

// VM names create computer names. These can be a max of 15 characters. So a different structure is required
var nameVM = 'vm${substring(workload, 0, 3)}${appNameShort}${role}${environmentLetter}${padLeft(index, 2, '0')}'


output name string = empty(customName) ? name : customName
output nameShort string = empty(customName) ? nameShort : customName
output nameGlobal string = empty(customName) ? nameGlobal : customName
output nameNoHyphen string = empty(customName) ? nameNoHyphen : customName
output nameVM string = empty(customName) ? nameVM : customName
