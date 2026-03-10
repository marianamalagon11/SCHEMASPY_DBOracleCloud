$ErrorActionPreference = 'Stop'

$root = $PSScriptRoot
$summaryDir = Join-Path $root 'output\diagrams\summary'
$relationshipsHtml = Join-Path $root 'output\relationships.html'
$dotExe = 'C:\Program Files\Graphviz\bin\dot.exe'

$compactDot = Join-Path $summaryDir 'relationships.real.compact.dot'
$largeDot = Join-Path $summaryDir 'relationships.real.large.dot'

if (!(Test-Path $dotExe) -or !(Test-Path $compactDot) -or !(Test-Path $largeDot) -or !(Test-Path $relationshipsHtml)) {
    exit 0
}

$compactPng = Join-Path $summaryDir 'relationships.real.compact.png'
$compactMap = Join-Path $summaryDir 'relationships.real.compact.map'
$largePng = Join-Path $summaryDir 'relationships.real.large.png'
$largeMap = Join-Path $summaryDir 'relationships.real.large.map'

Push-Location $summaryDir
try {
    & $dotExe -Tpng 'relationships.real.compact.dot' -o 'relationships.real.compact.png' | Out-Null
    & $dotExe -Tcmapx 'relationships.real.compact.dot' -o 'relationships.real.compact.map' | Out-Null
    & $dotExe -Tpng 'relationships.real.large.dot' -o 'relationships.real.large.png' | Out-Null
    & $dotExe -Tcmapx 'relationships.real.large.dot' -o 'relationships.real.large.map' | Out-Null
} finally {
    Pop-Location
}

if (!(Test-Path $compactPng) -or !(Test-Path $largePng) -or !(Test-Path $compactMap) -or !(Test-Path $largeMap)) {
    exit 0
}

$compactMapHtml = Get-Content $compactMap -Raw
$largeMapHtml = Get-Content $largeMap -Raw
$html = Get-Content $relationshipsHtml -Raw

$newSection = @"
                <section class="content">
                    <div class="box box-primary">
                        <div class="box-header with-border">
                            <i class="fa fa-sitemap"></i>
                            <h3 class="box-title">Compact Relationships</h3>
                        </div>
                        <div class="box-body">
                            <img id="relationshipsCompact" src="diagrams/summary/relationships.real.compact.png" usemap="#compactRelationshipsDiagram" style="max-width:100%;" alt="Compact relationships diagram" />
$compactMapHtml
                        </div>
                    </div>
                    <div class="box box-primary">
                        <div class="box-header with-border">
                            <i class="fa fa-project-diagram"></i>
                            <h3 class="box-title">Large Relationships</h3>
                        </div>
                        <div class="box-body">
                            <img id="relationshipsLarge" src="diagrams/summary/relationships.real.large.png" usemap="#largeRelationshipsDiagram" style="max-width:100%;" alt="Large relationships diagram" />
$largeMapHtml
                        </div>
                    </div>
                </section>
"@

$pattern = '(?s)\s*<section class="content">.*?</section>\s*</div>\s*<!-- /\.content-wrapper -->'
$replacement = "$newSection`r`n            </div>`r`n            <!-- /.content-wrapper -->"
$updated = [regex]::Replace($html, $pattern, $replacement, 1)

if ($updated -ne $html) {
    Set-Content -Path $relationshipsHtml -Value $updated -Encoding UTF8
}
