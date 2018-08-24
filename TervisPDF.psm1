function Rename-PDFsToOrderNumber {
    param (
        [Parameter(Mandatory=$true)]
        $PDFDirectory,
        [Parameter(Mandatory=$true)][ValidateSet("RueLaLa","DSG","Wayfair")]$Client
    )

    if ($Client -eq "RueLaLa") {
        [regex]$OrderNumberRegEx = "ORDER\sNUMBER\s+\d+"
    }
    if ($Client -eq "DSG") {
        [regex]$OrderNumberRegEx = "PO#:\s+\d+"
    }
    if ($Client -eq "Wayfair") {
        [regex]$OrderNumberRegEx = "P.O.\sNumber:\s+\S+"
	}
    $PDFFiles = Get-ChildItem -Path $PDFDirectory |
        where Name -like *.pdf

    New-Item -Path $PDFDirectory -Name RenamedFiles -ItemType Directory

    foreach ($PDF in $PDFFiles) {
        $PDFContents = Get-PDFContent -pdfFile $PDF.FullName
        $OrderNumberFound = $PDFContents -match $OrderNumberRegEx
        if ($OrderNumberFound) {
            $OrderNumberString = $Matches.Values.Split()
            $OrderNumber = $OrderNumberString -match {\w+\d+}
            if ($OrderNumber) {
                Move-Item -Path $PDF.FullName -Destination $PDFDirectory\RenamedFiles\$OrderNumber.pdf -Verbose
            }
        }
    }
}
