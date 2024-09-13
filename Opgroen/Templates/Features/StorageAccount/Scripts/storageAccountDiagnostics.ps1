param (
    [string] $resourceGroup
)

$contexts = (Get-AzStorageAccount -ResourceGroupName $resourceGroup).Context

foreach ($context in $contexts) {
    # Set metrics and retention
    Set-AzStorageServiceMetricsProperty -Context $context -ServiceType Blob -MetricsType Hour -MetricsLevel ServiceAndApi -RetentionDays 365
    Set-AzStorageServiceMetricsProperty -Context $context -ServiceType File -MetricsType Hour -MetricsLevel ServiceAndApi -RetentionDays 365
    Set-AzStorageServiceMetricsProperty -Context $context -ServiceType Table -MetricsType Hour -MetricsLevel ServiceAndApi -RetentionDays 365
    Set-AzStorageServiceMetricsProperty -Context $context -ServiceType Queue -MetricsType Hour -MetricsLevel ServiceAndApi -RetentionDays 365
   
    # Set logging and retention 
    Set-AzStorageServiceLoggingProperty -Context $context -ServiceType Blob -LoggingOperations read, write, delete -RetentionDays 365 -Version 1.0
    Set-AzStorageServiceLoggingProperty -Context $context -ServiceType Table -LoggingOperations read, write, delete -RetentionDays 365 -Version 1.0
    Set-AzStorageServiceLoggingProperty -Context $context -ServiceType Queue -LoggingOperations read, write, delete -RetentionDays 365 -Version 1.0
}