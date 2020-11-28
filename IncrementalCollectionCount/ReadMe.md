See [SCCM Incremental Updates Collection Maintenance](https://jameswassinger.me/sccm-device-collections-use-incremental-updates-for-this-collection/)

<p>SCCM Can only have 200 device collections set for incremental updating. This repo contains scripts to maintain this number.</p>

<p>note: schedule in Change-CMAutoIncCollections.ps1 is set to occur once a day.</p>

<p>to use download the scripts.</p>

* .\Get-CMAutoIncCollections -Path <Path_To_Store_Output_File>
* .\Change-CMAutoIncCollections -Path <Path_To_File_Containing_Collection_Names> -Date <Date_to_Set_Start>

<p>Examples</p>
* .\Get-CMAutoIncCollections -Path C:\CollectionNames.csv
* .\Change-CMAutoIncCollections -Path C:\CollectionNames.csv -Date "09/27/2018 9:00 AM"
