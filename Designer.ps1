# --------------------------------------------------------------------------------
# PowerShell-Designer - An app to Design Windows Forms for your PowerShell scripts
# --------------------------------------------------------------------------------

# Change the culture for the current session to "en-US" to force the application/script to use the list separator ',' instead of another one such as ';'.
# Source: https://stackoverflow.com/questions/59909992/temporarily-change-powershell-language-to-english/59910693#59910693
# It allows to avoid the following error:
<#
    Cannot convert value "800;600" to type "System.Int32".
    Error: "Input string was not in a correct format."
    At line:252 char:33 + ... $n[0] = [math]::Round(($n[0] / 1) * $tscale)
    + ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  + CategoryInfo : InvalidArgument:
    (:) [], RuntimeException  + FullyQualifiedErrorId : InvalidCastFromStringToInteger
#>

function Set-CultureWin([System.Globalization.CultureInfo] $culture) {
    [System.Threading.Thread]::CurrentThread.CurrentUICulture = $culture ;
    [System.Threading.Thread]::CurrentThread.CurrentCulture = $culture
} ;

Set-CultureWin en-US | Out-Null ; [system.threading.thread]::currentthread.currentculture | Out-Null

<#
MIT License
Copyright (c) 2020 Benjamin Turmo

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.


    .NOTES
    ===========================================================================
        FileName:     Designer.ps1
        Modified:     Analyth
        Created On:   1/15/2020
        Last Updated: 3/25/2023
        Version:      v2.1.8
    ===========================================================================

    .DESCRIPTION
        Use this script in the creation of other WinForms PowerShell scripts.  Has the ability to
        Save/Open a project, modify most properties of any control, and generate a script
        file.  The resulting script file initializes the Form in a STA runspace.

    .DEPENDENCIES
        PowerShell 4.0
        .Net

    .UPDATES
    1.0.0.1 - 06/13/2020
        Added MIT License
    1.0.1.0 - 06/20/2020
        Added DataGridView
        Corrected issue where able to add controls directly to TabControl instead of TabPage
    1.0.2.0 - 7/10/2020
        Added TabPage for TabControl
        Added SplitterPanel for SplitContainer
        Fixed Size property being saved when Dock set to Fill or AutoSize to true
        Updated UI: Moved Toolbox/Events to SplitterPanel in a TabControl on Mainform. All controls now
            in SplitContainers to allow for finer UI customization and to allow for maximization of
            the Mainform. There are some changes to the UI that were made in preparation for updating
            to a MDI child form and to allow for other future development.
    2.0.0.0 - 12/14/2020
        Complete UI Overhaul to make more traditional and allow for future feature additions/enhancement
        Property values being saved in the form XML is now dependent on the property reflector of the
            PropertyGrid GridItem. Does still keep track of every change because of issues with
            reflectors (see Known Issues).

        Unsupported:
            Multi-threading
            Drag/Drop addition of controls
            Adding Mouse Events to WebBrowser control
            Previous pre-2.0.0.0 version save files will not open properly in 2.0.0.0+
                If the Items Element is removed from Data it should load properly
        
        Known Issues:
            DataGridView - All CellStyle Properties will save, but get exception when setting on Open
            ListView - ListViewItem and ListViewGroup Properties will not save
            TreeView - Nodes property will not save
            TextBox - AutoCompleteCustomSource Property will not save
            Form - Unable to change IsMDIContainer to True and issue Maximizing Window State
            Certain property reflectors will show that a value has been changed when it has not. This
                issue affects the following properties on all controls: UseCompatibleTextRendering,
                TabIndex, and TabStop. In order for these properties to be saved to form XML they need
                to be manually changed in the PropertyGrid. After this point, the property value will
                always be generated in the form XML for that specific control.
            Images/Icons do not save
    2.0.1.0 - 12/26/2020
        Corrected issue after resizing of Form in design after resize to refresh parent Form
        Fixed issue with Size property on Forms and Textboxes to save correctly
	2.0.2.0 - 4/13/2022
		Removed FileDialog because it was unstable.
		Removed Global Context Menus because they were unstable.
		Fixed control attached Context Menus.
		Fixed generation of and behavior of common dialogs, which did not work previously.
		Fixed Save and Save As functions to not be locked to preset directory
		Assigned controls to variables rather than a script reference array and removed abstract reference table.
		If the VDS Module is installed, it is integrated into the script file output.
		Added DataGrid, HScrollBar, StatusStrip, TrackBar, VScrollBar,ToolStripButton,ToolStripSplitButton
	2.0.2.1 - 4/14/2022
		Changed location of vds module export, added to functions
		Added ToolStrip, just for layout purposes. Cannot add items within GUI
	2.0.2.2 - 4/15/2022
		Added FastColoredTextBox for editing events - attached to \Events.ps1
		Added 'RunLast' function
		'Copy' and 'Paste' shortcuts (CTRL+C, CTRL+V) broken by addition of FastColoredTextBox. Removed shortcuts.
		Created menu items and context menu for FastColoredTextBox
		Removed (unlisted in version 2.0.2.0) backup system now that Event outputs are much harder to overwrite.
	2.0.4 - 4/16/2022
		Changed some appearance elements. 
		Renamed this effort to PowerShell Designer with the intent to replace previous. 
		Renamed from WinFormsCreator to Designer.ps1. 
		Changed documents path
		Fixed SaveFildDialog path reference
		Fixed F9 for folders with spaces.
		Switched to Semantic Versioning, this product supercedes Powershell Designer 1.0.3
		Slicked to topnode if control add error.
	2.0.5 - 4/16/2022
		Fixed path issue when installing new version. 
	2.0.6 -  4/16/2022
		Fixed bug in path issue fix.
	2.0.7 -  4/16/2022
		Github repository created
	2.0.8 - 4/17/2022
		Fixed adding ToolStrip items
		Eliminated DialogShell info function calls
	2.0.9 - 4/18/2022
		In previous update removed vds module integration, not sure which.
		Added sender [sender] and events [e] parameters to control events	
		Scaling fix added for High Resolution Displays. Set Form 'Tag' Property to 'DPIAware' to attempt. See 'DPI Scaling.txt'
		Modern Visual Control Styles Added. Add the tag 'VisualStyle'
		Fixed bugs with File>New
		Adjustments to Size Buttons for window maximized. Added DesignerDPI.ps1 for clear text editing, adjusted math in that script for size buttons, but the controls will be squished at runtime (intentional, wontfix).
	2.0.10 4/19/2022
		Resolved issue with cancel on file open.
		Dot sourced events.ps1 to calc.ps1 and added VisualStyle tag.
	2.1.0 4/21/2022
		Changed tscale variable to ctscale for dialogshell compatibility. Call to variable in resize events must be updated to ctscale
		Here there be math involving scaling.
		DPIScale is now default mode for editing.
		DPIScale and VisualStyle are now defaults for new projects.
		Added status bar advising of $ctscale stuff.
	2.1.1 4/22/2022
		Reverted ctscale back to tscale due to cross compatibility issues.
		Refactored versioning. This (tscale) is no longer considered a breaking change, since it impacts no known published scripts.
		Added AutoNaming and AutoTexting controls by control type.
	2.1.2 4/24/2022
		Added FormName to FormText on New Project.
		Added a try-catch for loading FastColoredTextBox that should cause the script to be portable.
	2.1.3 4/25/2022
		Added warning concerning item collections in the property grid.
		Seperated edit and control menu.
		Fixed bug with timers causing them to not be initialized.
		Changed behavior of Paste Control to 'slick' to top node upon paste failure.
		Added image and icon embedding.
		Removed toolstrip due to buggy behavior. Toolstrip is now an alias for MenuStrip.
	2.1.4 4/26/2022
		Fixed double file dialog for icons, images
		Fixed WebBrowser control
		Fixed bug with direct control selection (accidental code delete in 2.1.3, restored)
		More control resize math for when client is maximized.
		Removed some problem attributes from export (image attributes) that are handled programmatically
		Added image import on solution open.
	2.1.5 4/27/2022
		Fixed bug with Powershell 7 not loading saved images.
		Added 'region Images' for collecting applied images and icons.
	2.1.6 4/28/2022
		Removed HScrollBar and VScrollBar due to support issues with DPI Scaling (these can still be added programmatically within 'events', if so multiply Width by $tscale for HScrollBar but exclude width, and the opposite is true for VScrollBar).
		Fixed minor bug involving ToolStripProgressBar sizing (Set AutoSize to False to save the size of this element)
		Fixed minor bug involving ToolStripSeparator
		Fixed bug loading projects with ImageScalingSize and MinimumSize attributes.
	2.1.7 4/29/2022
		Changed several message box dialogs to status bar label updates with timer instances.
    2.1.8 3/25/2023
        Added a function to force the application to run with 'en-US' culture to avoid a problem of conversion with the 'list separator'. en-US uses the list separator ',' and some other cultures uses ';' instead.
        Added a logo in base64 to improve the look.
        Increase the width of the left and right panel at opening (300 instead of 200).
		
BASIC MODIFICATIONS License
#This software has been modified from the original as tagged with #brandoncomputer
Original available at https://www.pswinformscreator.com/ for deeper comparison.
		
MIT License

Copyright (c) 2022 Brandon Cunningham

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
		
#>


# ScriptBlock to Execute in STA Runspace
$sbGUI = {
    param($BaseDir, $DPI)
	
    Add-Type @"
using System;
using System.Collections.Generic;
using System.Windows.Forms;
using System.Runtime.InteropServices;

public class psd {
		
		public static void SetCompat() 
		{
			//	SetProcessDPIAware();
	            Application.EnableVisualStyles();
            Application.SetCompatibleTextRenderingDefault(true);
		}
		
	    [System.Runtime.InteropServices.DllImport("user32.dll")]
        public static extern bool SetProcessDPIAware();
		
		[System.Runtime.InteropServices.DllImport("user32.dll")]
		public static extern bool SetProcessDpiAwarenessContext(int dpiFlag);
}
"@  -ReferencedAssemblies System.Windows.Forms, System.Drawing, System.Drawing.Primitives, System.Net.Primitives, System.ComponentModel.Primitives, Microsoft.Win32.Primitives

    [psd]::SetCompat()

    $DPI = 'dpi'

    $vscreen = [System.Windows.Forms.SystemInformation]::VirtualScreen.height
    if ($DPI.trim() -eq "dpi") {
        [psd]::SetProcessDPIAware()
        # [void][System.Windows.Forms.MessageBox]::Show("Controls cannot be positioned when the 'dpi' argument is passed.",'High DPI')
    }
    if ($dpi -eq $null) {
        [psd]::SetProcessDpiAwarenessContext(-5)
    }

    $screen = [System.Windows.Forms.SystemInformation]::VirtualScreen.height
    $global:tscale = ($screen / $vscreen)

    $global:control_track = @{}


    $global:tscale = 1


    #region Functions

    function Update-ErrorLog {
        param(
            [System.Management.Automation.ErrorRecord]$ErrorRecord,
            [string]$Message,
            [switch]$Promote
        )

        if ( $Message -ne '' ) { $Script:refs['tsl_StatusLabel'].text = "$($Message)" }#`r`n`r`nCheck '$($BaseDir)\exceptions.txt' for details."}

        $date = Get-Date -Format 'yyyyMMdd HH:mm:ss'
        $ErrorRecord | Out-File "$($BaseDir)\tmpError.txt"

        Add-Content -Path "$($BaseDir)\exceptions.txt" -Value "$($date): $($(Get-Content "$($BaseDir)\tmpError.txt") -replace "\s+"," ")"

        Remove-Item -Path "$($BaseDir)\tmpError.txt"

        if ( $Promote ) { throw $ErrorRecord }
    }

    function ConvertFrom-WinFormsXML {
        param(
            [Parameter(Mandatory = $true)]$Xml,
            [string]$Reference,
            $ParentControl,
            [switch]$Suppress
        )

        try {
            if ( $Xml.GetType().Name -eq 'String' ) { $Xml = ([xml]$Xml).ChildNodes }

            if ( $Xml.ToString() -ne 'SplitterPanel' ) { $newControl = New-Object System.Windows.Forms.$($Xml.ToString()) }
			
            #brandoncomputer_ToolStripAlias
            if ( $Xml.ToString() -eq 'ToolStrip' ) {
                $newControl = New-Object System.Windows.Forms.MenuStrip
                $ParentControl.Controls.Add($newControl)
            }

            if ( $ParentControl ) {
                if ( $Xml.ToString() -match "^ToolStrip" ) {
                    if ( $ParentControl.GetType().Name -match "^ToolStrip" ) { [void]$ParentControl.DropDownItems.Add($newControl) } else { [void]$ParentControl.Items.Add($newControl) }
                }
                elseif ( $Xml.ToString() -eq 'ContextMenuStrip' ) { $ParentControl.ContextMenuStrip = $newControl }
                elseif ( $Xml.ToString() -eq 'SplitterPanel' ) { $newControl = $ParentControl.$($Xml.Name.Split('_')[-1]) }
                else { $ParentControl.Controls.Add($newControl) }
            }
			
       
            $Xml.Attributes | ForEach-Object {
                $attrib = $_
                $attribName = $_.ToString()
								
                if ($attribName -eq 'Size') {
					
                    $n = $attrib.Value.split(',')
                    $n[0] = [math]::Round(($n[0] / 1) * $tscale)
                    $n[1] = [math]::Round(($n[1] / 1) * $tscale)
                    if ("$($n[0]),$($n[1])" -ne ",") {
                        $attrib.Value = "$($n[0]),$($n[1])"
                    }
                }
                if ($attribName -eq 'Location') {
                    $n = $attrib.Value.split(',')
                    $n[0] = [math]::Round(($n[0] / 1) * $tscale)
                    $n[1] = [math]::Round(($n[1] / 1) * $tscale)
                    if ("$($n[0]),$($n[1])" -ne ",") {
                        $attrib.Value = "$($n[0]),$($n[1])"
                    }
                }
                if ($attribName -eq 'MaximumSize') {
                    $n = $attrib.Value.split(',')
                    $n[0] = [math]::Round(($n[0] / 1) * $tscale)
                    $n[1] = [math]::Round(($n[1] / 1) * $tscale)
                    if ("$($n[0]),$($n[1])" -ne ",") {
                        $attrib.Value = "$($n[0]),$($n[1])"
                    }
                }
				
                if ($attribName -eq 'MinimumSize') {
                    $n = $attrib.Value.split(',')
                    $n[0] = [math]::Round(($n[0] / 1) * $tscale)
                    $n[1] = [math]::Round(($n[1] / 1) * $tscale)
                    if ("$($n[0]),$($n[1])" -ne ",") {
                        $attrib.Value = "$($n[0]),$($n[1])"
                    }
                }
                if ($attribName -eq 'ImageScalingSize') {
                    $n = $attrib.Value.split(',')
                    $n[0] = [math]::Round(($n[0] / 1) * $tscale)
                    $n[1] = [math]::Round(($n[1] / 1) * $tscale)
                    if ("$($n[0]),$($n[1])" -ne ",") {
                        $attrib.Value = "$($n[0]),$($n[1])"
                    }
                }
							
                if ( $Script:specialProps.Array -contains $attribName ) {
                    if ( $attribName -eq 'Items' ) {
                        $($_.Value -replace "\|\*BreakPT\*\|", "`n").Split("`n") | ForEach-Object { [void]$newControl.Items.Add($_) }
                    }
                    else {
                        # Other than Items only BoldedDate properties on MonthCalendar control
                        $methodName = "Add$($attribName)" -replace "s$"

                        $($_.Value -replace "\|\*BreakPT\*\|", "`n").Split("`n") | ForEach-Object { $newControl.$attribName.$methodName($_) }
                    }
                }
                else {
                    switch ($attribName) {
                        FlatAppearance {
                            $attrib.Value.Split('|') | ForEach-Object { $newControl.FlatAppearance.$($_.Split('=')[0]) = $_.Split('=')[1] }
                        }
                        default {
                            if ( $null -ne $newControl.$attribName ) {
                                if ( $newControl.$attribName.GetType().Name -eq 'Boolean' ) {
                                    if ( $attrib.Value -eq 'True' ) { $value = $true } else { $value = $false }
                                }
                                else { $value = $attrib.Value }
                            }
                            else { $value = $attrib.Value }
                            $newControl.$attribName = $value
                        }
                    }
                }

                if (( $attrib.ToString() -eq 'Name' ) -and ( $Reference -ne '' )) {
                    try { $refHashTable = Get-Variable -Name $Reference -Scope Script -ErrorAction Stop }
                    catch {
                        New-Variable -Name $Reference -Scope Script -Value @{} | Out-Null
                        $refHashTable = Get-Variable -Name $Reference -Scope Script -ErrorAction SilentlyContinue
                    }

                    $refHashTable.Value.Add($attrib.Value, $newControl)
                }
            }

            if ( $Xml.ChildNodes ) { $Xml.ChildNodes | ForEach-Object { ConvertFrom-WinformsXML -Xml $_ -ParentControl $newControl -Reference $Reference -Suppress } }

            if ( $Suppress -eq $false ) { return $newControl }
        }
        catch { Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered adding $($Xml.ToString()) to $($ParentControl.Name)" }
    }

    function Convert-XmlToTreeView {
        param(
            [System.Xml.XmlLinkedNode]$Xml,
            $TreeObject,
            [switch]$IncrementName
        )

        try {
            $controlType = $Xml.ToString()
            $controlName = "$($Xml.Name)"
			
            
            if ( $IncrementName ) {
                $objRef = Get-RootNodeObjRef -TreeNode $Script:refs['TreeView'].SelectedNode
                $returnObj = [pscustomobject]@{OldName = $controlName; NewName = "" }
                $loop = 1

                while ( $objRef.Objects.Keys -contains $controlName ) {
                    if ( $controlName.Contains('_') ) {
                        $afterLastUnderscoreText = $controlName -replace "$($controlName.Substring(0,($controlName.LastIndexOf('_') + 1)))"

                        if ( $($afterLastUnderscoreText -replace "\D").Length -eq $afterLastUnderscoreText.Length ) {
                            $controlName = $controlName -replace "_$($afterLastUnderscoreText)$", "_$([int]$afterLastUnderscoreText + 1)"
                        }
                        else { $controlName = $controlName + '_1' }
                    }
                    else { $controlName = $controlName + '_1' }

                    # Make sure does not cause infinite loop
                    if ( $loop -eq 1000 ) { throw "Unable to determine incremented control name." }
                    $loop++
                }

                $returnObj.NewName = $controlName
                $returnObj
            }

            if ( $controlType -ne 'SplitterPanel' ) { Add-TreeNode -TreeObject $TreeObject -ControlType $controlType -ControlName $controlName }

            $objRef = Get-RootNodeObjRef -TreeNode $Script:refs['TreeView'].SelectedNode
            $newControl = $objRef.Objects[$controlName]

            $Xml.Attributes.GetEnumerator().ForEach({
                    if ( $_.ToString() -ne 'Name' ) {
                        if ( $null -eq $objRef.Changes[$controlName] ) { $objRef.Changes[$controlName] = @{} }

                        if ( $null -ne $($newControl.$($_.ToString())) ) {
						
                            #brandoncomputer_loadformDPIFix
						
                            #begin dpi
						
                            #	info $_.ToString()
					
					
						
                            if ($_.ToString() -eq 'Size') {
					
                                $n = $_.Value.split(',')
                                $n[0] = [math]::Round(($n[0] / 1) * $tscale)
                                $n[1] = [math]::Round(($n[1] / 1) * $tscale)
                                if ("$($n[0]),$($n[1])" -ne ",") {
                                    $_.Value = "$($n[0]),$($n[1])"
                                }
                            }
                            if ($_.ToString() -eq 'Location') {
                                $n = $_.Value.split(',')
                                $n[0] = [math]::Round(($n[0] / 1) * $tscale)
                                $n[1] = [math]::Round(($n[1] / 1) * $tscale)
                                if ("$($n[0]),$($n[1])" -ne ",") {
                                    $_.Value = "$($n[0]),$($n[1])"
                                }
                            }
                            if ($_.ToString() -eq 'MaximumSize') {
                                $n = $_.Value.split(',')
                                $n[0] = [math]::Round(($n[0] / 1) * $tscale)
                                $n[1] = [math]::Round(($n[1] / 1) * $tscale)
                                if ("$($n[0]),$($n[1])" -ne ",") {
                                    $_.Value = "$($n[0]),$($n[1])"
                                }
                            }
				
                            if ($_.ToString() -eq 'MinimumSize') {
                                $n = $_.Value.split(',')
                                $n[0] = [math]::Round(($n[0] / 1) * $tscale)
                                $n[1] = [math]::Round(($n[1] / 1) * $tscale)
                                if ("$($n[0]),$($n[1])" -ne ",") {
                                    $_.Value = "$($n[0]),$($n[1])"
                                }
                            }
				
                            if ($_.ToString() -eq 'ImageScalingSize') {
                                $n = $_.Value.split(',')
                                $n[0] = [math]::Round(($n[0] / 1) * $tscale)
                                $n[1] = [math]::Round(($n[1] / 1) * $tscale)
                                if ("$($n[0]),$($n[1])" -ne ",") {
                                    $_.Value = "$($n[0]),$($n[1])"
                                }
                            }
				
				
						
                            #end dpi
						
						
                            if ( $($newControl.$($_.ToString())).GetType().Name -eq 'Boolean' ) {
                                if ( $_.Value -eq 'True' ) { $value = $true } else { $value = $false }
                            }
                            else { $value = $_.Value }
                        }
                        else { $value = $_.Value }
					
                        #brandoncomputer_ContextStripModify
				
                        try { if ($controlType -ne "ContextMenuStrip") { $newControl.$($_.ToString()) = $value } }
                        catch { if ( $_.Exception.Message -notmatch 'MDI container forms must be top-level' ) { throw $_ } }

                        $objRef.Changes[$controlName][$_.ToString()] = $_.Value
                    }
                })

            if ( $Xml.ChildNodes.Count -gt 0 ) {
                if ( $IncrementName ) { $Xml.ChildNodes.ForEach({ Convert-XmlToTreeView -Xml $_ -TreeObject $objRef.TreeNodes[$controlName] -IncrementName }) }
                else { $Xml.ChildNodes.ForEach({ Convert-XmlToTreeView -Xml $_ -TreeObject $objRef.TreeNodes[$controlName] }) }
            }
        }
        catch { Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered adding '$($Xml.ToString()) - $($Xml.Name)' to Treeview." }
    }

    function Get-CustomControl {
        param(
            [Parameter(Mandatory = $true)][hashtable]$ControlInfo,
            [string]$Reference,
            [switch]$Suppress
        )

        try {
            $refGuid = [guid]::NewGuid()
            $control = ConvertFrom-WinFormsXML -Xml "$($ControlInfo.XMLText)" -Reference $refGuid
            $refControl = Get-Variable -Name $refGuid -ValueOnly

            if ( $ControlInfo.Events ) { $ControlInfo.Events.ForEach({ $refControl[$_.Name]."add_$($_.EventType)"($_.ScriptBlock) }) }

            if ( $Reference -ne '' ) { New-Variable -Name $Reference -Scope Script -Value $refControl }

            Remove-Variable -Name refGuid -Scope Script

            if ( $Suppress -eq $false ) { return $control }
        }
        catch { Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered getting custom control." }
    }

    function Get-UserInputFromForm {
        param([string]$SetText)
        
        try {
            $inputForm = Get-CustomControl -ControlInfo $Script:childFormInfo['NameInput']

            if ( $inputForm ) {
                $inputForm.AcceptButton = $inputForm.Controls['StopDingOnEnter']

                $inputForm.Controls['UserInput'].Text = $SetText

                [void]$inputForm.ShowDialog()

                $returnVal = [pscustomobject]@{
                    Result  = $inputForm.DialogResult
                    NewName = $inputForm.Controls['UserInput'].Text
                }
                return $returnVal
            }
        }
        catch {
            Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered setting new control name."
        }
        finally {
            try { $inputForm.Dispose() }
            catch { if ( $_.Exception.Message -ne "You cannot call a method on a null-valued expression." ) { throw $_ } }
        }
    }

    function Add-TreeNode {
        param(
            $TreeObject,
            [string]$ControlType,
            [string]$ControlName,
            [string]$ControlText
        )
		
        #		info $TreeObject.ToString()
		
        if ($ControlText)
        {}
        else {
            if ($control_track.$controlType -eq $null) {
                $control_track[$controlType] = 1
            }
            else {
                $control_track.$controlType = $control_track.$controlType + 1
            }
        }
		
        #brandoncomputer_ToolStripAlias2		
        if ($ControlType -eq 'ToolStrip')
        { $ControlType = 'MenuStrip' }
		
		

        if ( $ControlName -eq '' ) {
            $userInput = Get-UserInputFromForm -SetText "$($Script:supportedControls.Where({$_.Name -eq $ControlType}).Prefix)_"

            if ( $userInput.Result -eq 'OK' ) { $ControlName = $userInput.NewName }
        }

        try {
            if ( $TreeObject.GetType().Name -eq 'TreeView' ) {
                if ( $ControlType -eq 'Form' ) {
                    # Clear the Assigned Events ListBox
                    $Script:refs['lst_AssignedEvents'].Items.Clear()
                    $Script:refs['lst_AssignedEvents'].Items.Add('No Events')
                    $Script:refs['lst_AssignedEvents'].Enabled = $false
                    
                    # Create the TreeNode
                    $newTreeNode = $TreeObject.Nodes.Add($ControlName, "Form - $($ControlName)")

	
                    # Create the Form
                    $form = New-Object System.Windows.Forms.Form
                    $form.Name = $ControlName
                    $form.text = $ControlName
                    $form.Height = 600
                    $form.Width = 800
                    $form.Location = New-Object System.Drawing.Point(0, 0)
                    $form.Add_FormClosing({
                            param($Sender, $e)

                            $e.Cancel = $true
                        })
					
                    $form.Add_Click({
                            if (( $Script:refs['PropertyGrid'].SelectedObject -ne $this ) -and ( $args[1].Button -eq 'Left' )) {
                                $Script:refs['TreeView'].SelectedNode = $Script:refsFID.Form.TreeNodes[$this.Name]
                            }
                        })
                    $form.Add_ReSize({
                            if ( $Script:refs['PropertyGrid'].SelectedObject -ne $this ) { $Script:refs['TreeView'].SelectedNode = $Script:refsFID.Form.TreeNodes[$this.Name] }

                            $Script:refs['PropertyGrid'].Refresh()

                            $this.ParentForm.Refresh()
						
                        })
                    $form.Add_LocationChanged({ $this.ParentForm.Refresh() })
                    $form.Add_ReSizeEnd({
                            if ( $Script:refs['PropertyGrid'].SelectedObject -ne $this ) { $Script:refs['TreeView'].SelectedNode = $Script:refsFID.Form.TreeNodes[$this.Name] }
                        
                            $Script:refs['PropertyGrid'].Refresh()

                            $this.ParentForm.Refresh()
                        })

                    # Add the selected object control buttons
                    $Script:sButtons = $null
                    Remove-Variable -Name sButtons -Scope Script -ErrorAction SilentlyContinue
                    #brandoncomputer_sizeButtons
                    ConvertFrom-WinFormsXML -ParentControl $form -Reference sButtons -Suppress -Xml '<Button Name="btn_SizeAll" Cursor="SizeAll" BackColor="White" Size="8,8" Visible="False" />'
                    ConvertFrom-WinFormsXML -ParentControl $form -Reference sButtons -Suppress -Xml '<Button Name="btn_TLeft" Cursor="SizeNWSE" BackColor="White" Size="8,8" Visible="False" />'
                    ConvertFrom-WinFormsXML -ParentControl $form -Reference sButtons -Suppress -Xml '<Button Name="btn_TRight" Cursor="SizeNESW" BackColor="White" Size="8,8" Visible="False" />'
                    ConvertFrom-WinFormsXML -ParentControl $form -Reference sButtons -Suppress -Xml '<Button Name="btn_BLeft" Cursor="SizeNESW" BackColor="White" Size="8,8" Visible="False" />'
                    ConvertFrom-WinFormsXML -ParentControl $form -Reference sButtons -Suppress -Xml '<Button Name="btn_BRight" Cursor="SizeNWSE" BackColor="White" Size="8,8" Visible="False" />'
                    ConvertFrom-WinFormsXML -ParentControl $form -Reference sButtons -Suppress -Xml '<Button Name="btn_MLeft" Cursor="SizeWE" BackColor="White" Size="8,8" Visible="False" />'
                    ConvertFrom-WinFormsXML -ParentControl $form -Reference sButtons -Suppress -Xml '<Button Name="btn_MRight" Cursor="SizeWE" BackColor="White" Size="8,8" Visible="False" />'
                    ConvertFrom-WinFormsXML -ParentControl $form -Reference sButtons -Suppress -Xml '<Button Name="btn_MTop" Cursor="SizeNS" BackColor="White" Size="8,8" Visible="False" />'
                    ConvertFrom-WinFormsXML -ParentControl $form -Reference sButtons -Suppress -Xml '<Button Name="btn_MBottom" Cursor="SizeNS" BackColor="White" Size="8,8" Visible="False" />'

                    # Add the Mouse events to each of the selected object control buttons
                    $sButtons.GetEnumerator().ForEach({
                            $_.Value.Add_MouseMove({
                                    param($Sender, $e)

                                    try {
                                        $currentMousePOS = [System.Windows.Forms.Cursor]::Position
                                        # If mouse button equals left and there was a change in mouse position (reduces flicker due to control refreshes during Move-SButtons)
                                        if (( $e.Button -eq 'Left' ) -and (( $currentMousePOS.X -ne $Script:oldMousePOS.X ) -or ( $currentMousePOS.Y -ne $Script:oldMousePOS.Y ))) {
                                
                                            if ( @('SplitterPanel', 'TabPage') -notcontains $Script:refs['PropertyGrid'].SelectedObject.GetType().Name ) {
                                                $sObj = $Script:sRect

                                                $msObj = @{}

                                                switch ($Sender.Name) {
                                                    btn_SizeAll {
                                                        if (( @('FlowLayoutPanel', 'TableLayoutPanel') -contains $Script:refs['PropertyGrid'].SelectedObject.Parent.GetType().Name ) -or
                                                       ( $Script:refs['PropertyGrid'].SelectedObject.Dock -ne 'None' )) {
                                                            $msObj.LocOffset = New-Object System.Drawing.Point(0, 0)
                                                        }
                                                        else {
                                                            $msObj.LocOffset = New-Object System.Drawing.Point(($currentMousePOS.X - $Script:oldMousePOS.X), ($currentMousePOS.Y - $Script:oldMousePOS.Y))
                                                        }
                                                        $newSize = $Script:sRect.Size
                                                    }
                                                    btn_TLeft {
                                                        $msObj.LocOffset = New-Object System.Drawing.Point(($currentMousePOS.X - $Script:oldMousePOS.X), ($currentMousePOS.Y - $Script:oldMousePOS.Y))
                                                        $newSize = New-Object System.Drawing.Size(($sObj.Size.Width + $Script:oldMousePOS.X - $currentMousePOS.X), ($sObj.Size.Height + $Script:oldMousePOS.Y - $currentMousePOS.Y))
                                                    }
                                                    btn_TRight {
                                                        $msObj.LocOffset = New-Object System.Drawing.Point(0, ($currentMousePOS.Y - $Script:oldMousePOS.Y))
                                                        $newSize = New-Object System.Drawing.Size(($sObj.Size.Width + $currentMousePOS.X - $Script:oldMousePOS.X), ($sObj.Size.Height + $Script:oldMousePOS.Y - $currentMousePOS.Y))
                                                    }
                                                    btn_BLeft {
                                                        $msObj.LocOffset = New-Object System.Drawing.Point(($currentMousePOS.X - $Script:oldMousePOS.X), 0)
                                                        $newSize = New-Object System.Drawing.Size(($sObj.Size.Width + $Script:oldMousePOS.X - $currentMousePOS.X), ($sObj.Size.Height + $currentMousePOS.Y - $Script:oldMousePOS.Y))
                                                    }
                                                    btn_BRight {
                                                        $msObj.LocOffset = New-Object System.Drawing.Point(0, 0)
                                                        $newSize = New-Object System.Drawing.Size(($sObj.Size.Width + $currentMousePOS.X - $Script:oldMousePOS.X), ($sObj.Size.Height + $currentMousePOS.Y - $Script:oldMousePOS.Y))
                                                    }
                                                    btn_MLeft {
                                                        $msObj.LocOffset = New-Object System.Drawing.Point(($currentMousePOS.X - $Script:oldMousePOS.X), 0)
                                                        $newSize = New-Object System.Drawing.Size(($sObj.Size.Width + $Script:oldMousePOS.X - $currentMousePOS.X), $sObj.Size.Height)
                                                    }
                                                    btn_MRight {
                                                        $msObj.LocOffset = New-Object System.Drawing.Point(0, 0)
                                                        $newSize = New-Object System.Drawing.Size(($sObj.Size.Width + $currentMousePOS.X - $Script:oldMousePOS.X), $sObj.Size.Height)
                                                    }
                                                    btn_MTop {
                                                        $msObj.LocOffset = New-Object System.Drawing.Point(0, ($currentMousePOS.Y - $Script:oldMousePOS.Y))
                                                        $newSize = New-Object System.Drawing.Size($sObj.Size.Width, ($sObj.Size.Height + $Script:oldMousePOS.Y - $currentMousePOS.Y))
                                                    }
                                                    btn_MBottom {
                                                        $msObj.LocOffset = New-Object System.Drawing.Point(0, 0)
                                                        $newSize = New-Object System.Drawing.Size($sObj.Size.Width, ($sObj.Size.Height + $currentMousePOS.Y - $Script:oldMousePOS.Y))
                                                    }
                                                }

                                                $msObj.Size = $newSize

                                                $Script:MouseMoving = $true
                                                Move-SButtons -Object $msObj
                                                $Script:MouseMoving = $false

                                                $refFID = $Script:refsFID.Form.Objects.Values.Where({ $_.GetType().Name -eq 'Form' })
                                                $clientParent = $Script:refs['PropertyGrid'].SelectedObject.Parent.PointToClient([System.Drawing.Point]::Empty)
                                                $clientForm = $refFID.PointToClient([System.Drawing.Point]::Empty)

                                                $newLocation = New-Object System.Drawing.Point(($Script:sRect.Location.X - (($clientParent.X - $clientForm.X) * -1)), ($Script:sRect.Location.Y - (($clientParent.Y - $clientForm.Y) * -1)))

                                                $Script:refs['PropertyGrid'].SelectedObject.Size = $Script:sRect.Size
                                                $Script:refs['PropertyGrid'].SelectedObject.Location = $newLocation
                                            }

                                            $Script:oldMousePos = $currentMousePOS

                                            $Script:refs['PropertyGrid'].Refresh()
                                        }
                                        else { $Script:oldMousePos = [System.Windows.Forms.Cursor]::Position }
                                    }
                                    catch { Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered while moving mouse over selected control." }
                                })
                            $_.Value.Add_MouseUp({
                                    #  Move-SButtons -Object $Script:refs['PropertyGrid'].SelectedObject
                                })
                        })

                    # Set MDIParent and Show Form
                    $form.MDIParent = $refs['MainForm']
                    $form.Show()

                    # Create reference object for the Form In Design
                    $Script:refsFID = @{
                        Form = @{
                            TreeNodes = @{"$($ControlName)" = $newTreeNode }
                            Objects   = @{"$($ControlName)" = $form }
                            Changes   = @{}
                            Events    = @{}
                        }
                    }
                }
                elseif (( @('ContextMenuStrip', 'Timer') -contains $ControlType ) -or ( $ControlType -match "Dialog$" )) {
                    $newTreeNode = $Script:refs['TreeView'].Nodes.Add($ControlName, "$($ControlType) - $($ControlName)")
                    
                    if ( $null -eq $Script:refsFID[$ControlType] ) { $Script:refsFID[$ControlType] = @{} }

                    $Script:refsFID[$ControlType][$ControlName] = @{
                        TreeNodes = @{"$($ControlName)" = $newTreeNode }
                        Objects   = @{"$($ControlName)" = New-Object System.Windows.Forms.$ControlType }
                        Changes   = @{}
                        Events    = @{}
                    }
                }
            }
            else {
                if (( $ControlName -ne '' ) -and ( $ControlType -ne 'SplitterPanel' )) {
                    $objRef = Get-RootNodeObjRef -TreeNode $TreeObject

                    if ( $objRef.Success -ne $false ) {
                        $newControl = New-Object System.Windows.Forms.$ControlType
                        $newControl.Name = $ControlName
						
                        switch ($ControlType) {
                            'DateTimePicker' {}
                            'WebBrowser' {}
                            default { $newControl.Text = $controlText }
                        }
                        if ($newControl.height) {
                            $newControl.height = $newControl.height * $tscale
                        }
                        if ($newControl.width) {
                            $newControl.width = $newControl.width * $tscale
                        }
                        #brandoncomputer_ImageScalingSize
                        if ($newControl.ImageScalingSize) {
                            $newControl.imagescalingsize = new-object System.Drawing.Size([int]($tscale * $newControl.imagescalingsize.width), [int]($tscale * $newControl.imagescalingsize.Height))
                        } 
                        #brandoncomputer_ToolStripException
                        if ( $ControlType -eq "ToolStrip" ) {
                            $objRef.Objects[$TreeObject.Name].Controls.Add($newControl)
                        }
                        else {
                            if ( $ControlType -match "^ToolStrip" ) {
                                if ( $objRef.Objects[$TreeObject.Name].GetType().Name -match "^ToolStrip" ) {
                                    if ($objRef.Objects[$TreeObject.Name].GetType().ToString() -eq "System.Windows.Forms.ToolStrip") {
                                        [void]$objRef.Objects[$TreeObject.Name].Items.Add($newControl)
                                    }
                                    else {
                                        [void]$objRef.Objects[$TreeObject.Name].DropDownItems.Add($newControl)
                                    }
                                }
								
                                else {
                                    [void]$objRef.Objects[$TreeObject.Name].Items.Add($newControl)
                                }
                            }
                            elseif ( $ControlType -eq 'ContextMenuStrip' ) {
                                $objRef.Objects[$TreeObject.Name].ContextMenuStrip = $newControl
                            }
                            else { $objRef.Objects[$TreeObject.Name].Controls.Add($newControl) }
                        }
						
					
                        if ($ControlType -ne 'WebBrowser') {						
                            try {
                                $newControl.Add_MouseUp({
                                        if (( $Script:refs['PropertyGrid'].SelectedObject -ne $this ) -and ( $args[1].Button -eq 'Left' )) {
                                            $Script:refs['TreeView'].SelectedNode = $Script:refsFID.Form.TreeNodes[$this.Name]
                                        }
                                    })
                            }
                            catch {
                                if ( $_.Exception.Message -notmatch 'not valid on this control' ) { throw $_ }
                            }
						
                        }

                        $newTreeNode = $TreeObject.Nodes.Add($ControlName, "$($ControlType) - $($ControlName)")
                        $objRef.TreeNodes[$ControlName] = $newTreeNode
                        $objRef.Objects[$ControlName] = $newControl

                        if ( $ControlType -eq 'SplitContainer' ) {
                            for ( $i = 1; $i -le 2; $i++ ) {
                                $objRef.TreeNodes["$($ControlName)_Panel$($i)"] = $newTreeNode.Nodes.Add("$($ControlName)_Panel$($i)", "SplitterPanel - $($ControlName)_Panel$($i)")
                                $objRef.Objects["$($ControlName)_Panel$($i)"] = $newControl."Panel$($i)"
                                $objRef.Objects["$($ControlName)_Panel$($i)"].Name = "$($ControlName)_Panel$($i)"
                                $objRef.Objects["$($ControlName)_Panel$($i)"].Add_MouseDown({
                                        if (( $Script:refs['PropertyGrid'].SelectedObject -ne $this ) -and ( $args[1].Button -eq 'Left' )) {
                                            $Script:refs['TreeView'].SelectedNode = $Script:refsFID.Form.TreeNodes[$this.Name]
                                        }
                                    })
                            }
                            
                            $newTreeNode.Expand()
                        }
                    }
                }
            }

            if ( $newTreeNode ) {
                $newTreeNode.ContextMenuStrip = $Script:reuseContext['TreeNode']
                $Script:refs['TreeView'].SelectedNode = $newTreeNode

                if (( $ControlType -eq 'TabControl' ) -and ( $Script:openingProject -eq $false )) { Add-TreeNode -TreeObject $newTreeNode -ControlType TabPage -ControlName 'Tab 1' }
				
            }
        }
        catch { Update-ErrorLog -ErrorRecord $_ -Message "Unable to add $($ControlName) to $($objRef.Objects[$TreeObject.Name])." }
    }

    function Get-ChildNodeList {
        param(
            $TreeNode,
            [switch]$Level
        )

        $returnVal = @()

        if ( $TreeNode.Nodes.Count -gt 0 ) {
            try {
                $TreeNode.Nodes.ForEach({
                        $returnVal += $(if ( $Level ) { "$($_.Level):$($_.Name)" } else { $_.Name })
                        $returnVal += $(if ( $Level ) { Get-ChildNodeList -TreeNode $_ -Level } else { Get-ChildNodeList -TreeNode $_ })
                    })
            }
            catch { Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered building Treenode list." }
        }

        return $returnVal
    }

    function Get-RootNodeObjRef {
        param([System.Windows.Forms.TreeNode]$TreeNode)

        try {
            if ( $TreeNode.Level -gt 0 ) { while ( $TreeNode.Parent ) { $TreeNode = $TreeNode.Parent } }

            $type = $TreeNode.Text -replace " - .*$"
            $name = $TreeNode.Name

            $returnVal = [pscustomobject]@{
                Success   = $true
                RootType  = $type
                RootName  = $name
                TreeNodes = ''
                Objects   = ''
                Changes   = ''
                Events    = ''
            }

            if ( $type -eq 'Form' ) {
                $returnVal.TreeNodes = $Script:refsFID[$type].TreeNodes
                $returnVal.Objects = $Script:refsFID[$type].Objects
                $returnVal.Changes = $Script:refsFID[$type].Changes
                $returnVal.Events = $Script:refsFID[$type].Events
            }
            elseif (( @('ContextMenuStrip', 'Timer') -contains $type ) -or ( $type -match "Dialog$" )) {
                $returnVal.TreeNodes = $Script:refsFID[$type][$name].TreeNodes
                $returnVal.Objects = $Script:refsFID[$type][$name].Objects
                $returnVal.Changes = $Script:refsFID[$type][$name].Changes
                $returnVal.Events = $Script:refsFID[$type][$name].Events
            }
            else { $returnVal.Success = $false }

            return $returnVal
        }
        catch { Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered determining root node object reference." }
    }

    function Move-SButtons {
        param($Object)
			
        if ($Object.GetType().Name -eq 'ToolStripProgressBar')
        { return }
		
        if ( ($Script:supportedControls.Where({ $_.Type -eq 'Parentless' }).Name + @('Form', 'ToolStripMenuItem', 'ToolStripComboBox', 'ToolStripTextBox', 'ToolStripSeparator', 'ContextMenuStrip')) -notcontains $Object.GetType().Name ) {
				      
            $newSize = $Object.Size
            if ( $Object.GetType().Name -ne 'HashTable' ) {

                $refFID = $Script:refsFID.Form.Objects.Values.Where({ $_.GetType().Name -eq 'Form' })
                $Script:sButtons.GetEnumerator().ForEach({ $_.Value.Visible = $true })
                $newLoc = $Object.PointToClient([System.Drawing.Point]::Empty)
                
                if ( $Script:MouseMoving -eq $true ) {
                    $clientParent = $Object.Parent.PointToClient([System.Drawing.Point]::Empty)
                    $clientForm = $refFID.PointToClient([System.Drawing.Point]::Empty)
					
                    $clientOffset = New-Object System.Drawing.Point((($clientParent.X - $clientForm.X) * -1), (($clientParent.Y - $clientForm.Y) * -1))
                }
                else { $clientOffset = New-Object System.Drawing.Point(0, 0) }
                
                #	info "bean"
                #	info ($Object.Left).ToString()
                #	$newLoc.X = ($newLoc.X * -1) - $Object.Left - ($refs['MainForm'].Location.X) - $clientOffset.X  - $Script:refs['ms_Left'].Size.Width #- (18 / $tscale)
                #	$newLoc.Y = ($newLoc.Y * -1) - $Object.Top - ($refs['MainForm'].Location.Y) - $clientOffset.Y #- (108 / $tscale)
                if ($tscale -gt 1) {
                    if ($Object.Parent.WindowState -eq "Maximized") {
                        $newLoc.X = ($newLoc.X * -1) - $refFID.Location.X - $refs['MainForm'].Location.X - $clientOffset.X - $Script:refs['ms_Left'].Size.Width - [math]::Round((15 * $tscale))
                        $newLoc.Y = ($newLoc.Y * -1) - $refFID.Location.Y - $refs['MainForm'].Location.Y - (20 * $tscale) - $clientOffset.Y - [math]::Round((((108 - ($tscale * 4 )) * $tscale) / 1))
                    }
                    else {
                        $newLoc.X = ($newLoc.X * -1) - $refFID.Location.X - $refs['MainForm'].Location.X - $clientOffset.X - $Script:refs['ms_Left'].Size.Width - [math]::Round((15 * $tscale))
                        #$newLoc.Y = ($newLoc.Y * -1) - $refFID.Location.Y - $refs['MainForm'].Location.Y - $clientOffset.Y - (100 * $tscale)
                        $newLoc.Y = ($newLoc.Y * -1) - $refFID.Location.Y - $refs['MainForm'].Location.Y - $clientOffset.Y - [math]::Round((((108 - ($tscale * 4 )) * $tscale) / 1))
                    }
                }
                else {
                    if ($Object.Parent.WindowState -eq "Maximized") {
                        $newLoc.X = ($newLoc.X * -1) - $refFID.Location.X - $refs['MainForm'].Location.X - $clientOffset.X - $Script:refs['ms_Left'].Size.Width - [math]::Round((18 * $tscale))
                        $newLoc.Y = ($newLoc.Y * -1) - $refFID.Location.Y - $refs['MainForm'].Location.Y - (20 * $tscale) - $clientOffset.Y - [math]::Round((108 * $tscale))
                    }
                    else {
                        $newLoc.X = ($newLoc.X * -1) - $refFID.Location.X - $refs['MainForm'].Location.X - $clientOffset.X - $Script:refs['ms_Left'].Size.Width - [math]::Round((18 * $tscale))
                        $newLoc.Y = ($newLoc.Y * -1) - $refFID.Location.Y - $refs['MainForm'].Location.Y - $clientOffset.Y - [math]::Round((108 * $tscale))
                    }
			
                }
		

		

                if ( $Script:refs['pnl_Left'].Visible -eq $true ) { $newLoc.X = $newLoc.X - $Script:refs['pnl_Left'].Size.Width - $Script:refs['lbl_Left'].Size.Width }
            }
            else { $newLoc = New-Object System.Drawing.Point(($Script:sButtons['btn_TLeft'].Location.X + $Object.LocOffset.X), ($Script:sButtons['btn_TLeft'].Location.Y + $Object.LocOffset.Y)) }

            $Script:sRect = New-Object System.Drawing.Rectangle($newLoc, $newSize)

            $Script:sButtons.GetEnumerator().ForEach({
                    $btn = $_.Value

                    switch ($btn.Name) {
                        btn_SizeAll { $btn.Location = New-Object System.Drawing.Point(($newLoc.X + 13), $newLoc.Y) }
                        btn_TLeft { $btn.Location = New-Object System.Drawing.Point($newLoc.X, $newLoc.Y) }
                        btn_TRight { $btn.Location = New-Object System.Drawing.Point(($newLoc.X + $newSize.Width - 8), $newLoc.Y) }
                        btn_BLeft { $btn.Location = New-Object System.Drawing.Point($newLoc.X, ($newLoc.Y + $newSize.Height - 8)) }
                        btn_BRight { $btn.Location = New-Object System.Drawing.Point(($newLoc.X + $newSize.Width - 8), ($newLoc.Y + $newSize.Height - 8)) }
                        btn_MLeft {
                            if ( $Object.Size.Height -gt 28 ) {
                                $btn.Location = New-Object System.Drawing.Point($newLoc.X, ($newLoc.Y + ($newSize.Height / 2) - 4))
                                $btn.Visible = $true
                            }
                            else { $btn.Visible = $false }
                        }
                        btn_MRight {
                            if ( $Object.Size.Height -gt 28 ) {
                                $btn.Location = New-Object System.Drawing.Point(($newLoc.X + $newSize.Width - 8), ($newLoc.Y + ($newSize.Height / 2) - 4))
                                $btn.Visible = $true
                            }
                            else { $btn.Visible = $false }
                        }
                        btn_MTop {
                            if ( $Object.Size.Width -gt 40 ) {
                                $btn.Location = New-Object System.Drawing.Point(($newLoc.X + ($newSize.Width / 2) - 4), $newLoc.Y)
                                $btn.Visible = $true
                            }
                            else { $btn.Visible = $false }
                        }
                        btn_MBottom {
                            if ( $Object.Size.Width -gt 40 ) {
                                $btn.Location = New-Object System.Drawing.Point(($newLoc.X + ($newSize.Width / 2) - 4), ($newLoc.Y + $newSize.Height - 8))
                                $btn.Visible = $true
                            }
                            else { $btn.Visible = $false }
                        }
                    }

                    $btn.BringToFront()
                    $btn.Refresh()
                })

            $Script:refs['PropertyGrid'].SelectedObject.Refresh()
            $Script:refs['PropertyGrid'].SelectedObject.Parent.Refresh()
        }
        else { $Script:sButtons.GetEnumerator().ForEach({ $_.Value.Visible = $false }) }
    }

    function Save-Project {
        param(
            [switch]$SaveAs,
            [switch]$Suppress,
            [switch]$ReturnXML
        )

        $projectName = $refs['tpg_Form1'].Text

        if ( $ReturnXML -eq $false ) {
            if (( $SaveAs ) -or ( $projectName -eq 'NewProject.fbs' )) {
                $saveDialog = ConvertFrom-WinFormsXML -Xml @"
<SaveFileDialog InitialDirectory="$($Script:projectsDir)" AddExtension="True" DefaultExt="fbs" Filter="fbs files (*.fbs)|*.fbs" FileName="$($projectName)" OverwritePrompt="True" ValidateNames="True" RestoreDirectory="True" />
"@
                $saveDialog.Add_FileOK({
                        param($Sender, $e)
                        if ( $($this.FileName | Split-Path -Leaf) -eq 'NewProject.fbs' ) {
                            [void][System.Windows.Forms.MessageBox]::Show("You cannot save a project with the file name 'NewProject.fbs'", 'Validation Error')
                            $e.Cancel = $true
                        }
                    })

                try {
                    [void]$saveDialog.ShowDialog()

                    if (( $saveDialog.FileName -ne '' ) -and ( $saveDialog.FileName -ne 'NewProject.fbs' )) { $projectName = $saveDialog.FileName | Split-Path -Leaf } else { $projectName = '' }
                }
                catch {
                    Update-ErrorLog -ErrorRecord $_ -Message 'Exception encountered while selecting Save file name.'
                    $projectName = ''
                }
                finally {
                    $saveDialog.Dispose()
                    #brandoncomputer_SaveDialogFix
                    $global:projectDirName = $saveDialog.FileName
                    Remove-Variable -Name saveDialog
                }
            }
        }

        if ( $projectName -ne '' ) {
            try {
                $xml = New-Object -TypeName XML
                $xml.LoadXml('<Data><Events Desc="Events associated with controls"></Events></Data>')
                $tempPGrid = New-Object System.Windows.Forms.PropertyGrid
                $tempPGrid.PropertySort = 'Alphabetical'

                $Script:refs['TreeView'].Nodes.ForEach({
                        $currentNode = $xml.Data
                        $rootControlType = $_.Text -replace " - .*$"
                        $rootControlName = $_.Name

                        $objRef = Get-RootNodeObjRef -TreeNode $($Script:refs['TreeView'].Nodes | Where-Object { $_.Name -eq $rootControlName -and $_.Text -match "^$($rootControlType)" })

                        $nodeIndex = @("0:$($rootControlName)")
                        $nodeIndex += Get-ChildNodeList -TreeNode $objRef.TreeNodes[$rootControlName] -Level

                        @(0..($nodeIndex.Count - 1)).ForEach({
                                $nodeName = $nodeIndex[$_] -replace "^\d+:"
                                $newElementType = $objRef.Objects[$nodeName].GetType().Name
                                [int]$nodeDepth = $nodeIndex[$_] -replace ":.*$"

                                $newElement = $xml.CreateElement($newElementType)
                                $newElement.SetAttribute("Name", $nodeName)

                                $tempPGrid.SelectedObject = $objRef.Objects[$nodeName]

                                # Set certain properties first
                                $Script:specialProps.Before.ForEach({
                                        $prop = $_
                                        $tempGI = $tempPGrid.SelectedGridItem.Parent.GridItems.Where({ $_.PropertyLabel -eq $prop })

                                        if ( $tempGI.Count -gt 0 ) {
                                            if ( $tempGI.PropertyDescriptor.ShouldSerializeValue($tempGI.Component) ) { $newElement.SetAttribute($tempGI.PropertyLabel, $tempGI.GetPropertyTextValue()) }
                                        }
                                    })

                                # Set other attributes
                                $tempPGrid.SelectedGridItem.Parent.GridItems.ForEach({
                                        $checkReflector = $true
                                        $tempGI = $_
                            
                                        if ( $Script:specialProps.All -contains $tempGI.PropertyLabel ) {
                                            switch ($tempGI.PropertyLabel) {
                                                Location {
                                                    if (( $tempPGrid.SelectedObject.Dock -ne 'None' ) -or
                                           ( $tempPGrid.SelectedObject.Parent.GetType().Name -eq 'FlowLayoutPanel' ) -or
                                           (( $newElementType -eq 'Form' ) -and ( $tempPGrid.SelectedObject.StartPosition -ne 'Manual' )) -or
                                           ( $tempGI.GetPropertyTextValue() -eq '0, 0' )) {
                                                        $checkReflector = $false
                                                    }
                                                }
                                                Size {
                                                    # Only check reflector for Size when AutoSize is false and Dock not set to Fill
                                                    if (( $tempPGrid.SelectedObject.AutoSize -eq $true ) -or ( $tempPGrid.SelectedObject.Dock -eq 'Fill' )) {
                                                        # If control is disabled sometimes AutoSize will return $true even if $false
                                                        if (( $tempPGrid.SelectedObject.AutoSize -eq $true ) -and ( $tempPGrid.SelectedObject.Enabled -eq $false )) {
                                                            $tempPGrid.SelectedObject.Enabled = $true

                                                            if ( $tempGI.PropertyDescriptor.ShouldSerializeValue($tempGI.Component) ) { $newElement.SetAttribute($tempGI.PropertyLabel, $tempGI.GetPropertyTextValue()) }

                                                            $tempPGrid.SelectedObject.Enabled = $false
                                                        }

                                                        $checkReflector = $false

                                                        # Textbox has an issue here
                                                        if (( $newElementType -eq 'Textbox' ) -and ( $tempPGrid.SelectedObject.Size.Width -ne 100 )) { $checkReflector = $true }
                                                    }
                                                    # Form has an issue here
                                                    if (( $newElementType -eq 'Form' ) -and ( $tempPGrid.SelectedObject.Size -eq (New-Object System.Drawing.Size(300, 300)) )) { $checkReflector = $false }
                                                }
                                                FlatAppearance {
                                                    if ( $tempPGrid.SelectedObject.FlatStyle -eq 'Flat' ) {
                                                        $value = ''

                                                        $tempGI.GridItems.ForEach({
                                                                if ( $_.PropertyDescriptor.ShouldSerializeValue($_.Component.FlatAppearance) ) { $value += "$($_.PropertyLabel)=$($_.GetPropertyTextValue())|" }
                                                            })

                                                        if ( $value -ne '' ) { $newElement.SetAttribute('FlatAppearance', $($value -replace "\|$")) }
                                                    }

                                                    $checkReflector = $false
                                                }
                                                default {
                                                    # If property has a bad reflector and it has been changed manually add the attribute
                                                    if (( $Script:specialProps.BadReflector -contains $_ ) -and ( $null -ne $objRef.Changes[$_] )) { $newElement.SetAttribute($_, $objRef.Changes[$_]) }

                                                    $checkReflector = $false
                                                }
                                            }
                                        }

                                        if ( $checkReflector ) {
                                            if ( $tempGI.PropertyDescriptor.ShouldSerializeValue($tempGI.Component) ) {
                                                $newElement.SetAttribute($tempGI.PropertyLabel, $tempGI.GetPropertyTextValue())
                                            }
                                            elseif (( $newElementType -eq 'Form' ) -and ( $tempGI.PropertyLabel -eq 'Size') -and ( $tempPGrid.SelectedObject.AutoSize -eq $false )) {
                                                $newElement.SetAttribute($tempGI.PropertyLabel, $tempGI.GetPropertyTextValue())
                                            }
                                        }

                                        [void]$currentNode.AppendChild($newElement)
                                    })

                                # Set certain properties last
                                $Script:specialProps.After.ForEach({
                                        $prop = $_
                                        $tempGI = $tempPGrid.SelectedGridItem.Parent.GridItems.Where({ $_.PropertyLabel -eq $prop })

                                        if ( $tempGI.Count -gt 0 ) {
                                            if ( $Script:specialProps.Array -contains $prop ) {
                                                if ( $prop -eq 'Items' ) {
                                                    if ( $objRef.Objects[$nodeName].Items.Count -gt 0 ) {
                                                        if ( @('CheckedListBox', 'ListBox', 'ComboBox', 'ToolStripComboBox') -contains $newElementType ) {
                                                            $value = ''

                                                            $objRef.Objects[$nodeName].Items.ForEach({ $value += "$($_)|*BreakPT*|" })

                                                            $newElement.SetAttribute('Items', $($value -replace "\|\*BreakPT\*\|$"))
                                                        }
                                                        else {
                                                            switch ($newElementType) {
                                                                'MenuStrip' {}
                                                                'ContextMenuStrip' {}
                                                                'StatusStrip' {}
                                                                'ToolStrip' {}
                                                                #'ListView' {}
                                                                default { if ( $ReturnXML -eq $false ) { [void][System.Windows.Forms.MessageBox]::Show("$($newElementType) items will not save", 'Notification') } }
                                                            }
                                                        }
                                                    }
                                                }
                                                else {
                                                    if ( $objRef.Objects[$nodeName].$prop.Count -gt 0 ) {
                                                        $value = ''

                                                        $objRef.Objects[$nodeName].$prop.ForEach({ $value += "$($_)|*BreakPT*|" })

                                                        $newElement.SetAttribute($prop, $($value -replace "\|\*BreakPT\*\|$"))
                                                    }
                                                }
                                            }
                                            else {
                                                if ( $tempGI.PropertyDescriptor.ShouldSerializeValue($tempGI.Component) ) { $newElement.SetAttribute($tempGI.PropertyLabel, $tempGI.GetPropertyTextValue()) }
                                            }
                                        }
                                    })

                                # Set assigned Events
                                if ( $objRef.Events[$nodeName] ) {
                                    $newEventElement = $xml.CreateElement($newElementType)
                                    $newEventElement.SetAttribute('Name', $nodeName)
                                    $newEventElement.SetAttribute('Root', "$($objRef.RootType)|$rootControlName")

                                    $eventString = ''
                                    $objRef.Events[$nodeName].ForEach({ $eventString += "$($_) " })

                                    $newEventElement.SetAttribute('Events', $($eventString -replace " $"))

                                    [void]$xml.Data.Events.AppendChild($newEventElement)
                                }

                                # Set $currentNode for the next iteration
                                if ( $_ -lt ($nodeIndex.Count - 1) ) {
                                    [int]$nextNodeDepth = "$($nodeIndex[($_+1)] -replace ":.*$")"

                                    if ( $nextNodeDepth -gt $nodeDepth ) { $currentNode = $newElement }
                                    elseif ( $nextNodeDepth -lt $nodeDepth ) { @(($nodeDepth - 1)..$nextNodeDepth).ForEach({ $currentNode = $currentNode.ParentNode }) }
                                }
                            })
                    })
				
                $nodes = $xml.SelectNodes('//*')
                foreach ($node in $nodes) {
                    if ($dpi -eq 'dpi') {
					
                        if ($node.Size) {
					
                            $n = ($node.Size).split(',')
                            $n[0] = [math]::round(($n[0] / 1) / $tscale)
                            $n[1] = [math]::round(($n[1] / 1) / $tscale)
                            if ("$($n[0]),$($n[1])" -ne ",") {
                                $node.Size = "$($n[0]),$($n[1])"
                            }
                        }
                        if ($node.Location) {
                            $n = ($node.Location).split(',')
                            $n[0] = [math]::round(($n[0] / 1) / $tscale)
                            $n[1] = [math]::round(($n[1] / 1) / $tscale)
                            if ("$($n[0]),$($n[1])" -ne ",") {
                                $node.Location = "$($n[0]),$($n[1])"
                            }
                        }
                        if ($node.MaximumSize) {
                            $n = ($node.MaximumSize).split(',')
                            $n[0] = [math]::round(($n[0] / 1) / $tscale)
                            $n[1] = [math]::round(($n[1] / 1) / $tscale)
                            if ("$($n[0]),$($n[1])" -ne ",") {
                                $node.MaximumSize = "$($n[0]),$($n[1])"
                            }
                        }
				
                        if ($node.MinimumSize) {
                            $n = ($node.MinimumSize).split(',')
                            $n[0] = [math]::round(($n[0] / 1) / $tscale)
                            $n[1] = [math]::round(($n[1] / 1) / $tscale)
                            if ("$($n[0]),$($n[1])" -ne ",") {
                                $node.MinimumSize = "$($n[0]),$($n[1])"
                            }
                        }
				
                        if ($node.ImageScalingSize) {
                            $n = ($node.ImageScalingSize).split(',')
                            $n[0] = [math]::round(($n[0] / 1) / $tscale)
                            $n[1] = [math]::round(($n[1] / 1) / $tscale)
                            if ("$($n[0]),$($n[1])" -ne ",") {
                                $node.ImageScalingSize = "$($n[0]),$($n[1])"
                            }
                        }
				
                    }
                    $nodes.RemoveAttribute('ContextMenuStrip')
                    $nodes.RemoveAttribute('Image')
                    $nodes.RemoveAttribute('Icon')
                    $nodes.RemoveAttribute('BackgroundImage')
                    $nodes.RemoveAttribute('ErrorImage')
                    $nodes.RemoveAttribute('InitialImage')
					
                }
				
                if ( $ReturnXML ) { return $xml }
                else {
                    #brandoncomputer_SaveFix
                    #$xml.Save("$($Script:projectsDir)\$($projectName)")
                    $xml.Save($global:projectDirName)

                    $refs['tpg_Form1'].Text = $projectName
					
                    #brandoncomputer_FastTextSaveFile
                    $generationPath = "$(Split-Path -Path $global:projectDirName)\$($projectName -replace "\..*$")"
                    if (Test-Path -path $generationPath) {
                        #do nothing
                    }
                    else {
                        New-Item -ItemType directory -Path $generationPath
                    }
                    $ascii = new-object System.Text.ASCIIEncoding
                    $FastText.SaveToFile("$generationPath\Events.ps1", $ascii)


                    if ( $Suppress -eq $false ) { $Script:refs['tsl_StatusLabel'].text = 'Successfully Saved!' }
                }
            }
            catch {
                if ( $ReturnXML ) {
                    Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered while generating Form XML."
                    return $xml
                }
                else { Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered while saving project." }
            }
            finally {
                if ( $tempPGrid ) { $tempPGrid.Dispose() }
            }
        }
        else { throw 'SaveCancelled' }
    }
    
    #endregion Functions

    #region Event ScriptBlocks

    $eventSB = @{
        'MainForm'             = @{
            FormClosing = {
                try {
                    $Script:refs['TreeView'].Nodes.ForEach({
                            $controlName = $_.Name
                            $controlType = $_.Text -replace " - .*$"

                            if ( $controlType -eq 'Form' ) { $Script:refsFID.Form.Objects[$controlName].Dispose() }
                            else { $Script:refsFID[$controlType][$controlName].Objects[$controlName].Dispose() }
                        })
                }
                catch { Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered during Form closure." }
            }
        }
        'New'                  = @{
            Click = {
				
                try {
					
                    if ( [System.Windows.Forms.MessageBox]::Show("Unsaved changes to the current project will be lost.  Are you sure you want to start a new project?", 'Confirm', 4) -eq 'Yes' ) {
                        $global:control_track = @{}
                        $projectName = "NewProject.fbs"
                        $FastText.Clear()
                        $FastText.SelectedText = "#region Images
						
#endregion

"

                        try {
                            $FastText.CollapseFoldingBlock(0)
                        }
                        catch {}
						
                        $refs['tpg_Form1'].Text = $projectName
                        $Script:refs['TreeView'].Nodes.ForEach({
                                $controlName = $_.Name
                                $controlType = $_.Text -replace " - .*$"

                                if ( $controlType -eq 'Form' ) { $Script:refsFID.Form.Objects[$controlName].Dispose() }
                                else { $Script:refsFID[$controlType][$controlName].Objects[$ControlName].Dispose() }
                            })

                        $Script:refs['TreeView'].Nodes.Clear()

                        Add-TreeNode -TreeObject $Script:refs['TreeView'] -ControlType Form -ControlName MainForm
                        #brandoncomputer_newResize
                        $Script:refsFID.Form.Objects[$($Script:refs['TreeView'].Nodes | Where-Object { $_.Text -match "^Form - " }).Name].height = $Script:refsFID.Form.Objects[$($Script:refs['TreeView'].Nodes | Where-Object { $_.Text -match "^Form - " }).Name].height * $tscale
                        $Script:refsFID.Form.Objects[$($Script:refs['TreeView'].Nodes | Where-Object { $_.Text -match "^Form - " }).Name].width = $Script:refsFID.Form.Objects[$($Script:refs['TreeView'].Nodes | Where-Object { $_.Text -match "^Form - " }).Name].width * $tscale
                        $Script:refsFID.Form.Objects[$($Script:refs['TreeView'].Nodes | Where-Object { $_.Text -match "^Form - " }).Name].tag = "VisualStyle,DPIAware"
						
                        $baseicon = $Script:refsFID.Form.Objects[$($Script:refs['TreeView'].Nodes | Where-Object { $_.Text -match "^Form - " }).Name].Icon
					
                    }
                }
                catch { Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered during start of New Project." }
            }
        }
        'Open'                 = @{
            Click = {
                if ( [System.Windows.Forms.MessageBox]::Show("You will lose all changes to the current project.  Are you sure?", 'Confirm', 4) -eq 'Yes' ) {
                    $openDialog = ConvertFrom-WinFormsXML -Xml @"
<OpenFileDialog InitialDirectory="$($Script:projectsDir)" AddExtension="True" DefaultExt="fbs" Filter="fbs files (*.fbs)|*.fbs" FilterIndex="1" ValidateNames="True" CheckFileExists="True" RestoreDirectory="True" />
"@
                    try {
                        $Script:openingProject = $true

                        if ( $openDialog.ShowDialog() -eq 'OK' ) {
                            $fileName = $openDialog.FileName
                            if ($openDialog.FileName) {
                                $global:control_track = @{}
                            
                                New-Object -TypeName XML | ForEach-Object {
                                    $_.Load("$($fileName)")

                                    $Script:refs['TreeView'].BeginUpdate()

                                    $Script:refs['TreeView'].Nodes.ForEach({
                                            $controlName = $_.Name
                                            $controlType = $_.Text -replace " - .*$"

                                            if ( $controlType -eq 'Form' ) { $Script:refsFID.Form.Objects[$controlName].Dispose() }
                                            else { $Script:refsFID[$controlType][$controlName].Objects[$ControlName].Dispose() }
                                        })

                                    $Script:refs['TreeView'].Nodes.Clear()

                                    Convert-XmlToTreeView -XML $_.Data.Form -TreeObject $Script:refs['TreeView']

                                    $_.Data.ChildNodes.Where({ $_.ToString() -notmatch 'Form' -and $_.ToString() -notmatch 'Events' }) | ForEach-Object { Convert-XmlToTreeView -XML $_ -TreeObject $Script:refs['TreeView'] }

                                    $Script:refs['TreeView'].EndUpdate()

                                    if ( $_.Data.Events.ChildNodes.Count -gt 0 ) {
                                        $_.Data.Events.ChildNodes | ForEach-Object {
                                            $rootControlType = $_.Root.Split('|')[0]
                                            $rootControlName = $_.Root.Split('|')[1]
                                            $controlName = $_.Name

                                            if ( $rootControlType -eq 'Form' ) {
                                                $Script:refsFID.Form.Events[$controlName] = @()
                                                $_.Events.Split(' ') | ForEach-Object { $Script:refsFID.Form.Events[$controlName] += $_ }
                                            }
                                            else {
                                                $Script:refsFID[$rootControlType][$rootControlName].Events[$controlName] = @()
                                                $_.Events.Split(' ') | ForEach-Object { $Script:refsFID[$rootControlType][$rootControlName].Events[$controlName] += $_ }
                                            }
                                        }
                                    }
                                }
                                #>
                                $objRef = Get-RootNodeObjRef -TreeNode $Script:refs['TreeView'].SelectedNode

                                if ( $objRef.Events[$Script:refs['TreeView'].SelectedNode.Name] ) {
                                    $Script:refs['lst_AssignedEvents'].BeginUpdate()
                                    $Script:refs['lst_AssignedEvents'].Items.Clear()

                                    [void]$Script:refs['lst_AssignedEvents'].Items.AddRange($objRef.Events[$Script:refs['TreeView'].SelectedNode.Name])

                                    $Script:refs['lst_AssignedEvents'].EndUpdate()

                                    $Script:refs['lst_AssignedEvents'].Enabled = $true
                                }
                            }
                        }

                        $Script:openingProject = $false
						
                        if ($openDialog.FileName) {

                            $Script:refsFID.Form.Objects[$($Script:refs['TreeView'].Nodes | Where-Object { $_.Text -match "^Form - " }).Name].Visible = $true
                            $Script:refs['tpg_Form1'].Text = "$($openDialog.FileName -replace "^.*\\")"
                            $Script:refs['TreeView'].SelectedNode = $Script:refs['TreeView'].Nodes | Where-Object { $_.Text -match "^Form - " }
                            #brandoncomputer_OpenDialogFix					

                            $global:projectDirName = $openDialog.FileName
                            #brandoncomputer_FastTextOpenFile
                            $projectName = $Script:refs['tpg_Form1'].Text
                            $generationPath = "$(Split-Path -Path $global:projectDirName)\$($projectName -replace "\..*$")"
					
						
					
                            if (Test-Path -path "$generationPath\Events.ps1") {
                                $FastText.OpenFile("$generationPath\Events.ps1")	
                                $fastArr = ($FastText.Text).split("
")
                                foreach ($arrItem in $fastArr) {
                                    $dotSplit = $arrItem.split(".")
                                    if ($dotSplit[1]) {
                                        $spaceSplit = $dotSplit[1].Split(" ")
                                        $baseStr = $arrItem.split(" ")[0]
                                        $noCash = $baseStr.split("`$")[1]
                                        if ($noCash.count -gt 0) {
                                            $Control = $noCash.Split(".")[0]
                                            $b64 = $arrItem.split("`"")[1]
                                            switch ($spaceSplit[0]) {
                                                'Icon' {
                                                    $objRef.Objects[$Control].Icon = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap][System.Drawing.Image]::FromStream([System.IO.MemoryStream][System.Convert]::FromBase64String($b64))).GetHicon())
                                                }
                                                'Image' {
                                                    $objRef.Objects[$Control].Image = [System.Drawing.Image]::FromStream([System.IO.MemoryStream][System.Convert]::FromBase64String($b64))
                                                }
                                                'BackgroundImage' {
                                                    $objRef.Objects[$Control].BackgroundImage = [System.Drawing.Image]::FromStream([System.IO.MemoryStream][System.Convert]::FromBase64String($b64))
                                                }
                                                'ErrorImage' {
                                                    $objRef.Objects[$Control].ErrorImage = [System.Drawing.Image]::FromStream([System.IO.MemoryStream][System.Convert]::FromBase64String($b64))
                                                }
                                                'InitialImage' {
                                                    $objRef.Objects[$Control].BackgroundImage = [System.Drawing.Image]::FromStream([System.IO.MemoryStream][System.Convert]::FromBase64String($b64))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
						
                            try {
                                $FastText.CollapseFoldingBlock(0)
                            }
                            catch {}
					


                        }
					
                    }
                    catch { Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered while opening $($fileName)." }
                    finally {
                        $Script:openingProject = $false

                        $openDialog.Dispose()
                        Remove-Variable -Name openDialog

                        $Script:refs['TreeView'].Focus()
						
                    }
                }
            }
        }
        'Rename'               = @{
            Click = {
                if ( $Script:refs['TreeView'].SelectedNode.Text -notmatch "^SplitterPanel" ) {
                    $currentName = $Script:refs['TreeView'].SelectedNode.Name
                    $userInput = Get-UserInputFromForm -SetText $currentName

                    if ( $userInput.Result -eq 'OK' ) {
                        try {
                            $newName = $userInput.NewName

                            $objRef = Get-RootNodeObjRef -TreeNode $Script:refs['TreeView'].SelectedNode

                            $objRef.Objects[$currentName].Name = $newName
                            $objRef.Objects[$newName] = $objRef.Objects[$currentName]
                            $objRef.Objects.Remove($currentName)

                            if ( $objRef.Changes[$currentName] ) {
                                $objRef.Changes[$newName] = $objRef.Changes[$currentName]
                                $objRef.Changes.Remove($currentName)
                            }

                            if ( $objRef.Events[$currentName] ) {
                                $objRef.Events[$newName] = $objRef.Events[$currentName]
                                $objRef.Events.Remove($currentName)
                            }

                            $objRef.TreeNodes[$currentName].Name = $newName
                            $objRef.TreeNodes[$currentName].Text = $Script:refs['TreeView'].SelectedNode.Text -replace "-.*$", "- $($newName)"
                            $objRef.TreeNodes[$newName] = $objRef.TreeNodes[$currentName]
                            $objRef.TreeNodes.Remove($currentName)

                            if ( $objRef.TreeNodes[$newName].Text -match "^SplitContainer" ) {
                                @('Panel1', 'Panel2').ForEach({
                                        $objRef.Objects["$($currentName)_$($_)"].Name = "$($newName)_$($_)"
                                        $objRef.Objects["$($newName)_$($_)"] = $objRef.Objects["$($currentName)_$($_)"]
                                        $objRef.Objects.Remove("$($currentName)_$($_)")

                                        if ( $objRef.Changes["$($currentName)_$($_)"] ) {
                                            $objRef.Changes["$($newName)_$($_)"] = $objRef.Changes["$($currentName)_$($_)"]
                                            $objRef.Changes.Remove("$($currentName)_$($_)")
                                        }

                                        if ( $objRef.Events["$($currentName)_$($_)"] ) {
                                            $objRef.Events["$($newName)_$($_)"] = $objRef.Events["$($currentName)_$($_)"]
                                            $objRef.Events.Remove("$($currentName)_$($_)")
                                        }

                                        $objRef.TreeNodes["$($currentName)_$($_)"].Name = "$($newName)_$($_)"
                                        $objRef.TreeNodes["$($currentName)_$($_)"].Text = $Script:refs['TreeView'].SelectedNode.Text -replace "-.*$", "- $($newName)_$($_)"
                                        $objRef.TreeNodes["$($newName)_$($_)"] = $objRef.TreeNodes["$($currentName)_$($_)"]
                                        $objRef.TreeNodes.Remove("$($currentName)_$($_)")
                                    })
                            }
                        }
                        catch { Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered renaming '$($Script:refs['TreeView'].SelectedNode.Text)'." }
                    }
                }
                else { [void][System.Windows.Forms.MessageBox]::Show("Cannot perform any action from the 'Edit' Menu against a SplitterPanel control.", 'Restricted Action') }
            }
        }
        'Delete'               = @{
            Click = {
                if ( $Script:refs['TreeView'].SelectedNode.Text -notmatch "^SplitterPanel" ) {
                    try {
                        $objRef = Get-RootNodeObjRef -TreeNode $Script:refs['TreeView'].SelectedNode
                        
                        if (( $objRef.Success -eq $true ) -and ( $Script:refs['TreeView'].SelectedNode.Level -ne 0 ) -or ( $objRef.RootType -ne 'Form' )) {
                            if ( [System.Windows.Forms.MessageBox]::Show("Are you sure you wish to remove the selected node and all child nodes? This cannot be undone." , "Confirm Removal" , 4) -eq 'Yes' ) {
                                # Generate array of TreeNodes to delete
									
                                $nodesToDelete = @($($Script:refs['TreeView'].SelectedNode).Name)
                                $nodesToDelete += Get-ChildNodeList -TreeNode $Script:refs['TreeView'].SelectedNode
                                
                                (($nodesToDelete.Count - 1)..0).ForEach({
                                        # If the node is currently copied remove nodeClipboard
                                        if ( $objRef.TreeNodes[$nodesToDelete[$_]] -eq $Script:nodeClipboard.Node ) {
                                            $Script:nodeClipboard = $null
                                            Remove-Variable -Name nodeClipboard -Scope Script
                                        }

                                        # Dispose of the Form control and remove it from the Form object
                                        if ( $objRef.TreeNodes[$nodesToDelete[$_]].Text -notmatch "^SplitterPanel" ) { $objRef.Objects[$nodesToDelete[$_]].Dispose() }
                                        $objRef.Objects.Remove($nodesToDelete[$_])

                                        # Remove the actual TreeNode from the TreeView control and remove it from the Form object
                                        $objRef.TreeNodes[$nodesToDelete[$_]].Remove()
                                        $objRef.TreeNodes.Remove($nodesToDelete[$_])

                                        # Remove any changes or assigned events associated with the deleted TreeNodes from the Form object
                                        if ( $objRef.Changes[$nodesToDelete[$_]] ) { $objRef.Changes.Remove($nodesToDelete[$_]) }
                                        if ( $objRef.Events[$nodesToDelete[$_]] ) { $objRef.Events.Remove($nodesToDelete[$_]) }
                                    })
                            }
                        }
                        else { $Script:refs['tsl_StatusLabel'].text = 'Cannot delete the root Form.  Start a New Project instead.' }
                    }
                    catch { Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered deleting '$($Script:refs['TreeView'].SelectedNode.Text)'." }
                }
                else { [void][System.Windows.Forms.MessageBox]::Show("Cannot perform any action from the 'Edit' Menu against a SplitterPanel control.", 'Restricted Action') }
            }
        }
        'CopyNode'             = @{
            Click = {
                if ( $Script:refs['TreeView'].SelectedNode.Level -gt 0 ) {
                    $Script:nodeClipboard = @{
                        ObjRef = Get-RootNodeObjRef -TreeNode $Script:refs['TreeView'].SelectedNode
                        Node   = $Script:refs['TreeView'].SelectedNode
                    }
                }
                else { [void][System.Windows.Forms.MessageBox]::Show('You cannot copy a root node.  It will be necessary to copy each individual subnode separately after creating the root node manually.') }
            }
        }
        'PasteNode'            = @{
            Click = {
                try {
                    if ( $Script:nodeClipboard ) {
                        $pastedObjType = $Script:nodeClipboard.Node.Text -replace " - .*$"
                        $currentObjType = $Script:refs['TreeView'].SelectedNode.Text -replace " - .*$"

                        if ( $Script:supportedControls.Where({ $_.Name -eq $currentObjType }).ChildTypes -contains $Script:supportedControls.Where({ $_.Name -eq $pastedObjType }).Type ) {
                            $pastedObjName = $Script:nodeClipboard.Node.Name
                            $objRef = Get-RootNodeObjRef -TreeNode $Script:refs['TreeView'].SelectedNode

                            $xml = Save-Project -ReturnXML

                            $pastedXML = Select-Xml -Xml $xml -XPath "//$($Script:nodeClipboard.ObjRef.RootType)[@Name=`"$($Script:nodeClipboard.ObjRef.RootName)`"]//$($pastedObjType)[@Name=`"$($pastedObjName)`"]"

                            $Script:refs['TreeView'].BeginUpdate()

                            if (( $objRef.RootType -eq $Script:nodeClipboard.ObjRef.RootType ) -and ( $objRef.RootName -eq $Script:nodeClipboard.ObjRef.RootName )) {
                                [array]$newNodeNames = Convert-XmlToTreeView -TreeObject $Script:refs['TreeView'].SelectedNode -Xml $pastedXml.Node -IncrementName
                            }
                            else { [array]$newNodeNames = Convert-XmlToTreeView -TreeObject $Script:refs['TreeView'].SelectedNode -Xml $pastedXml.Node }

                            $Script:refs['TreeView'].EndUpdate()

                            Move-SButtons -Object $refs['PropertyGrid'].SelectedObject

                            $newNodeNames.ForEach({ if ( $Script:nodeClipboard.ObjRef.Events["$($_.OldName)"] ) { $objRef.Events["$($_.NewName)"] = $Script:nodeClipboard.ObjRef.Events["$($_.OldName)"] } })
                        }
                        else {
                            $pastedObjName = $Script:nodeClipboard.Node.Name
                            $objRef = Get-RootNodeObjRef -TreeNode $Script:refs['TreeView'].TopNode

                            $xml = Save-Project -ReturnXML

                            $pastedXML = Select-Xml -Xml $xml -XPath "//$($Script:nodeClipboard.ObjRef.RootType)[@Name=`"$($Script:nodeClipboard.ObjRef.RootName)`"]//$($pastedObjType)[@Name=`"$($pastedObjName)`"]"

                            $Script:refs['TreeView'].BeginUpdate()

                            if (( $objRef.RootType -eq $Script:nodeClipboard.ObjRef.RootType ) -and ( $objRef.RootName -eq $Script:nodeClipboard.ObjRef.RootName )) {
                                [array]$newNodeNames = Convert-XmlToTreeView -TreeObject $Script:refs['TreeView'].TopNode -Xml $pastedXml.Node -IncrementName
                            }
                            else { [array]$newNodeNames = Convert-XmlToTreeView -TreeObject $Script:refs['TreeView'].TopNode -Xml $pastedXml.Node }

                            $Script:refs['TreeView'].EndUpdate()

                            Move-SButtons -Object $refs['PropertyGrid'].SelectedObject

                            $newNodeNames.ForEach({ if ( $Script:nodeClipboard.ObjRef.Events["$($_.OldName)"] ) { $objRef.Events["$($_.NewName)"] = $Script:nodeClipboard.ObjRef.Events["$($_.OldName)"] } })				
                        }
                    }
                }
                catch { Update-ErrorLog -ErrorRecord $_ -Message 'Exception encountered while pasting node from clipboard.' }
            }
        }
        'Move Up'              = @{
            Click = {
                try {
                    $selectedNode = $Script:refs['TreeView'].SelectedNode
                    $objRef = Get-RootNodeObjRef -TreeNode $selectedNode
                    $nodeName = $selectedNode.Name
                    $nodeIndex = $selectedNode.Index

                    if ( $nodeIndex -gt 0 ) {
                        $parentNode = $selectedNode.Parent
                        $clone = $selectedNode.Clone()

                        $parentNode.Nodes.Remove($selectedNode)
                        $parentNode.Nodes.Insert($($nodeIndex - 1), $clone)

                        $objRef.TreeNodes[$nodeName] = $parentNode.Nodes[$($nodeIndex - 1)]
                        $Script:refs['TreeView'].SelectedNode = $objRef.TreeNodes[$nodeName]
                    }
                }
                catch { Update-ErrorLog -ErrorRecord $_ -Message 'Exception encountered increasing index of TreeNode.' }
            }
        }
        'Move Down'            = @{
            Click = {
                try {
                    $selectedNode = $Script:refs['TreeView'].SelectedNode
                    $objRef = Get-RootNodeObjRef -TreeNode $selectedNode
                    $nodeName = $selectedNode.Name
                    $nodeIndex = $selectedNode.Index

                    if ( $nodeIndex -lt $($selectedNode.Parent.Nodes.Count - 1) ) {
                        $parentNode = $selectedNode.Parent
                        $clone = $selectedNode.Clone()

                        $parentNode.Nodes.Remove($selectedNode)
                        if ( $nodeIndex -eq $($parentNode.Nodes.Count - 1) ) { $parentNode.Nodes.Add($clone) }
                        else { $parentNode.Nodes.Insert($($nodeIndex + 1), $clone) }

                        $objRef.TreeNodes[$nodeName] = $parentNode.Nodes[$($nodeIndex + 1)]
                        $Script:refs['TreeView'].SelectedNode = $objRef.TreeNodes[$nodeName]
                    }
                }
                catch { Update-ErrorLog -ErrorRecord $_ -Message 'Exception encountered decreasing index of TreeNode.' }
            }
        }
        'Generate Script File' = @{
            Click = {
                if ( [System.Windows.Forms.MessageBox]::Show('Before generating the script file changes will need to be saved.  Would you like to continue?', 'Confirm', 4) -eq 'Yes' ) {
                    try {
                        Save-Project -Suppress

                        # If the generate child form doesn't already exist, create it. It only gets created once, so does not reset each time called
                        if ( $null -eq $Script:refsGenerate ) {
                            Get-CustomControl -ControlInfo $Script:childFormInfo['Generate'] -Reference refsGenerate
                            # Now that it's created it can be removed from $childFormInfo
                            $Script:childFormInfo.Remove('Generate')
                        }

                        $Script:refsGenerate['Generate'].DialogResult = 'Cancel'
                        $Script:refsGenerate['Generate'].AcceptButton = $Script:refsGenerate['btn_Generate']

                        $projectName = $Script:refs['tpg_Form1'].Text
                        #brandoncomputer_GenerationPathFix
                        $projectFilePath = $global:projectDirName
                        Split-Path -Path $global:projectDirName
                        $generationPath = "$(Split-Path -Path $global:projectDirName)\$($projectName -replace "\..*$")"

                        $xmlText = Get-Content -Path "$($projectFilePath)"
                        [xml]$xml = $xmlText
                        # Disable checkboxes based on necessity
                        #brandoncomputer_Unsure
                        if ( $xml.Data.Events.ChildNodes.Count -gt 0 ) { $Script:refsGenerate['cbx_Events'].Enabled = $true } else { $Script:refsGenerate['cbx_Events'].Enabled = $false }
                        if ( $Script:refsGenerate['gbx_ChildForms'].Controls.Count -gt 2 ) { $Script:refsGenerate['cbx_ChildForms'].Enabled = $true } else { $Script:refsGenerate['cbx_ChildForms'].Enabled = $false }
                        if ( $xml.Data.ContextMenuStrip ) { $Script:refsGenerate['cbx_ReuseContext'].Enabled = $true } else { $Script:refsGenerate['cbx_ReuseContext'].Enabled = $false }
                        if ( $xml.Data.Timer ) { $Script:refsGenerate['cbx_Timers'].Enabled = $true } else { $Script:refsGenerate['cbx_Timers'].Enabled = $false }
                        if ( $xml.Data.ChildNodes.ToString() -match "Dialog$" ) { $Script:refsGenerate['cbx_Dialogs'].Enabled = $true } else { $Script:refsGenerate['cbx_Dialogs'].Enabled = $false }

                        if ( $Script:refsGenerate['Generate'].ShowDialog() -eq 'OK' ) {
                            if ( (Test-Path -Path "$($generationPath)" -PathType Container) -eq $false ) { New-Item -Path "$($generationPath)" -ItemType Directory | Out-Null }

                            if ( $xmlText -match "^  </Form>" ) {
                                $indexFormStart = [array]::IndexOf($xmlText, $xmlText -match "^  <Form ")
                                $indexFormEnd = [array]::IndexOf($xmlText, "  </Form>")
                                $formText = $xmlText[$($indexFormStart)..$($indexFormEnd)]
                            }
                            else { $formText = $xmlText -match "^  <Form " }

                            # Start script generation
                            $scriptText = New-Object System.Collections.Generic.List[String]
                            #$scriptText.AddRange($Script:templateText.Notes)
                            $Script:templateText.Notes.ForEach({ $scriptText.Add($_) })

                            $scriptText[3] = $scriptText[3] -replace 'FNAME', "$($projectName -replace "fbs$","ps1")"
                            $scriptText[4] = $scriptText[4] -replace 'NETNAME', "$($env:USERNAME)"
                            $scriptText[5] = $scriptText[5] -replace "  DATE", "  $(Get-Date -Format 'yyyy/MM/dd')"
                            $scriptText[6] = $scriptText[6] -replace "  DATE", "  $(Get-Date -Format 'yyyy/MM/dd')"

                            $Script:templateText.Start_STAScriptBlock.ForEach({ $scriptText.Add($_) })

                            # Functions
                            $Script:templateText.StartRegion_Functions.ForEach({ $scriptText.Add($_) })
                            #brandoncomputer_Scale
                            $tag = $Script:refsFID.Form.Objects[$($Script:refs['TreeView'].Nodes | Where-Object { $_.Text -match "^Form - " }).Name].Tag
                            if ($tag -like "*DPIAware*") {
                                $scriptText.Add("	`$vscreen = [System.Windows.Forms.SystemInformation]::VirtualScreen.height")
                                $scriptText.Add("[psd]::SetProcessDPIAware()")
                                $scriptText.Add("	`$screen = [System.Windows.Forms.SystemInformation]::VirtualScreen.height")
                                $scriptText.Add("	`$script:tscale = (`$screen/`$vscreen)")
                            }
                            if ($tag -like "*VisualStyle*") {
                                $scriptText.Add("	[psd]::SetCompat()")
                            }
                            <# 							
#brandoncomputer_AddVDSModule
							
							if ( (Test-Path -Path "$(path $(Get-Module -ListAvailable vds).path)" -PathType Container) -eq $true ) {
								$vdsArr = (get-content -path "$(path $(Get-Module -ListAvailable vds).path)\vds.psm1").split([Environment]::NewLine)
								foreach ($arrItem in $vdsArr){
									$scriptText.Add($arrItem)
								}
							} #>
							
                            $Script:templateText.Function_Update_ErrorLog.ForEach({ $scriptText.Add($_) })
                            $Script:templateText.Function_ConvertFrom_WinFormsXML.ForEach({ $scriptText.Add($_) })
                            if (( $Script:refsGenerate['gbx_ChildForms'].Controls.Count -gt 2 ) -or ( $xml.Data.ChildNodes.Count -gt 3 )) { $Script:templateText.Function_Get_CustomControl.ForEach({ $scriptText.Add($_) }) }

                            $Script:templateText.EndRegion_Functions.ForEach({ $scriptText.Add($_) })

                            # Event Scriptblocks
                            #brandoncomputer_OldScriptBlockAbstraction
                            <#                             if ( $($xml.Data.Events.ChildNodes | Where-Object { $_.Root -match "^Form" }) ) {
                                $Script:templateText.StartRegion_Events.ForEach({$scriptText.Add($_)})

                                $xml.Data.Events.ChildNodes | Where-Object { $_.Root -match "^Form" } | ForEach-Object {
                                    $name = $_.Name

                                    $scriptText.Add("        '$name' = @{")

                                    $_.Events -Split ' ' | ForEach-Object {
                                        ([string[]]`
                                            "            $_ = {",
                                            "",
                                            "            }"
                                        ).ForEach({$scriptText.Add($_)})
                                    }

                                    $scriptText.Add("        }")
                                }

                                $Script:templateText.EndRegion_Events.ForEach({$scriptText.Add($_)})
                            } #>
							

							
							

                            
                            # Child Forms
                            if ( $Script:refsGenerate['gbx_ChildForms'].Controls.Count -gt 2 ) {
                                $Script:templateText.StartRegion_ChildForms.ForEach({ $scriptText.Add($_) })

                                (1..$(($Script:refsGenerate['gbx_ChildForms'].Controls | Where-Object { $_.Name -match "tbx_ChildForm" }).Count - 1)).ForEach({
                                        $controlName = "tbx_ChildForm$($_)"

                                        $childXmlText = Get-Content -Path "$($($Script:refsGenerate['gbx_ChildForms'].Controls[$controlName]).Tag)"

                                        $indexFormStart = [array]::IndexOf($childXmlText, $childXmlText -match "^  <Form ")
                                        $indexFormEnd = [array]::IndexOf($childXmlText, "  </Form>")
                                        $childFormText = $childXmlText[$($indexFormStart)..$($indexFormEnd)]

                                        $childXml = New-Object -TypeName Xml
                                        $childXml.LoadXml($childXmlText)

                                        $childFormName = $childXml.Data.Form.Name

                                    ([string[]]`
                                            "        '$childFormName' = @{",
                                        "            XMLText = @`""
                                    ).ForEach({ $scriptText.Add($_) })

                                        $childFormText.ForEach({ $scriptText.Add($_) })

                                        $scriptText.Add("`"@")

                                        if ( ($childXml.Data.Events.ChildNodes | Where-Object { $_.Root -match "^Form" }) ) {
                                            $scriptText.Add('            Events = @(')

                                            $childXml.Data.Events.ChildNodes | Where-Object { $_.Root -match "^Form" } | ForEach-Object {
                                                $name = $_.Name

                                                $_.Events -Split ' ' | ForEach-Object {
                                                ([string[]]`
                                                        "                [pscustomobject]@{",
                                                    "                    Name = '$($name)'",
                                                    "                    EventType = '$($_)'",
                                                    "                    ScriptBlock = {",
                                                    "",
                                                    "                    }",
                                                    "                },"
                                                ).ForEach({ $scriptText.Add($_) })
                                                }
                                            }

                                            $scriptText[-1] = $scriptText[-1] -replace ","

                                            $scriptText.Add("            )")
                                            $scriptText.Add("        }")
                                        }
                                    })

                                $Script:templateText.EndRegion_ChildForms.ForEach({ $scriptText.Add($_) })
                            }

                            # Timers / Reusable ContextMenuStrips
                            $dialogRegionStarted = $false
                            $dialogCount = 0
                            $controlScriptInit = ''

                            (@('Timer', 'ContextMenuStrip') + $supportedControls.Where({ $_.Name -match "Dialog$" }).Name).ForEach({
                                    $childTypeName = $_

                                    if ( $xml.Data.$childTypeName ) {
                                        if ( $childTypeName -match "Dialog$" ) {
                                            if ( $dialogRegionStarted -eq $false ) {
                                                $dialogRegionStarted = $true
                                                $Script:templateText.StartRegion_Dialogs.ForEach({ $scriptText.Add($_) })
                                                $dialogCountMax = $xml.Data.ChildNodes.Where({ $_.ToString() -match "Dialog$" }).Count
                                            }
                                        }
                                        else { $Script:templateText."StartRegion_$($childTypeName)s".ForEach({ $scriptText.Add($_) }) }
                                        $xml.Data.$childTypeName | ForEach-Object {
                                            $controlName = $_.Name
                                            $startIndex = [array]::IndexOf($xmlText, $xmlText -match "^  <$($childTypeName) Name=`"$($controlName)`"")
                                            $keepProcessing = $true
                                            $controlText = @()

                                        ($startIndex..$($xmlText.Count - 2)).ForEach({
                                                    if ( $keepProcessing ) {
                                                        if (( $xmlText[$_] -eq "  </$($childTypeName)>" ) -or ( $xmlText[$_] -match "^  <$($childTypeName).*/>$" )) { $keepProcessing = $false }

                                                        $controlText += $xmlText[$_]
                                                    }
                                                })
										
                                            if ($childTypeName -eq "Timer") {
                                                $controlScriptInit += "`$$controlName = ConvertFrom-WinFormsXML -Xml `$Script:timerInfo[`'$controlName`'].XMLText
"		
                                            }
                                            else {
                                                $controlScriptInit += "`$$controlName = ConvertFrom-WinFormsXML -Xml `$Script:dialoginfo[`'$controlName`'].XMLText
"			
                                            }
                                            $scriptText.Add("        '$controlName' = @{")
                                            $scriptText.Add("            XMLText = @`"")
                                            $controlText | ForEach-Object { $scriptText.Add($_) }
                                            $scriptText.Add("`"@")

                                            if ( $xml.Data.Events.ChildNodes | Where-Object { $_.Root -eq "$($childTypeName)|$($controlName)" } ) {
                                                $scriptText.Add('            Events = @(')

                                                $xml.Data.Events.ChildNodes | Where-Object { $_.Root -match "$($childTypeName)|$($controlName)" } | ForEach-Object {
                                                    $name = $_.Name

                                                    $_.Events -Split ' ' | ForEach-Object {
                                                    ([string[]]`
                                                            "                [pscustomobject]@{",
                                                        "                    Name = '$($name)'",
                                                        "                    EventType = '$($_)'",
                                                        "                    ScriptBlock = {",
                                                        "",
                                                        "                    }",
                                                        "                },"
                                                    ).ForEach({ $scriptText.Add($_) })
                                                    }
                                                }

                                                $scriptText[-1] = $scriptText[-1] -replace ","

                                                $scriptText.Add("            )")
                                                $scriptText.Add("        }")
                                            }
                                            else { $scriptText.Add("        }") }
                                            #brandoncomputer_DialogCount
                                            $dialogCount = $dialogCount + 1
                                        }

                                        if ( $childTypeName -match "Dialog$" ) {
                                            if ( $dialogCount -ge $dialogCountMax ) { $Script:templateText.EndRegion_Dialogs.ForEach({ $scriptText.Add($_) }) }
                                        }
                                        else { $Script:templateText."EndRegion_$($childTypeName)s".ForEach({ $scriptText.Add($_) }) }
                                    }
                                })
							
                            # Environment Setup
                            $Script:templateText.Region_EnvSetup.ForEach({ $scriptText.Add($_) })
							
							
                            # Insert Dot Sourcing of files (make sure EnvSetup is before Timers
                            if ( $Script:refsGenerate['gbx_DotSource'].Controls.Checked -contains $true ) {
                                ([string[]]`
                                    "    #region Dot Sourcing of files",
                                "",
                                "    `$dotSourceDir = `$BaseDir",
                                ""
                                ).ForEach({ $scriptText.Add($_) })

                                if ( $Script:refsGenerate['cbx_Functions'].Checked ) { $scriptText.Add("    . `"`$(`$dotSourceDir)\$($Script:refsGenerate['tbx_Functions'].Text)`"") }
                                if ( $Script:refsGenerate['cbx_ChildForms'].Checked ) { $scriptText.Add("    . `"`$(`$dotSourceDir)\$($Script:refsGenerate['tbx_ChildForms'].Text)`"") }
                                if ( $Script:refsGenerate['cbx_Dialogs'].Checked ) { $scriptText.Add("    . `"`$(`$dotSourceDir)\$($Script:refsGenerate['tbx_Dialogs'].Text)`"") }
                                if ( $Script:refsGenerate['cbx_ReuseContext'].Checked ) { $scriptText.Add("    . `"`$(`$dotSourceDir)\$($Script:refsGenerate['tbx_ReuseContext'].Text)`"") }
                                if ( $Script:refsGenerate['cbx_EnvSetup'].Checked ) { $scriptText.Add("    . `"`$(`$dotSourceDir)\$($Script:refsGenerate['tbx_EnvSetup'].Text)`"") }
                                if ( $Script:refsGenerate['cbx_Timers'].Checked ) { $scriptText.Add("    . `"`$(`$dotSourceDir)\$($Script:refsGenerate['cbx_Timers'].Text)`"") }
								
								
                                ([string[]]`
                                    "",
                                "    #endregion Dot Sourcing of files",
                                ""
                                ).ForEach({ $scriptText.Add($_) })
                            }

                            # Form Initialization
                            ([string[]]`
                                "    #region Form Initialization",
                            "",
                            "    try {",
                            "        ConvertFrom-WinFormsXML -Reference refs -Suppress -Xml @`""
                            ).ForEach({ $scriptText.Add($_) })

                            $formText | ForEach-Object { $scriptText.Add($_) }

                            ([string[]]`
                                "`"@",
                            "    } catch {Update-ErrorLog -ErrorRecord `$_ -Message `"Exception encountered during Form Initialization.`"}",
                            "",
                            "    #endregion Form Initialization",
                            ""
                            ).ForEach({ $scriptText.Add($_) })
							
                            $scriptText.Add($controlScriptInit)
							
                            #brandoncomputer_NotSure
                            if ( $Script:refsGenerate['cbx_Events'].Checked ) { $scriptText.Add("    . `"`$(`$dotSourceDir)\$($Script:refsGenerate['tbx_Events'].Text)`"") }
							
                            # Event Assignment
                            if ( $xml.Data.Events.ChildNodes | Where-Object { $_.Root -match "^Form" } ) {
                                $Script:templateText.StartRegion_Events.ForEach({ $scriptText.Add($_) })

                                $xml.Data.Events.ChildNodes | Where-Object { $_.Root -match "^Form" } | ForEach-Object {
                                    $name = $_.Name

                                    $_.Events -Split ' ' | ForEach-Object {
                                        #brandoncomputer_RemoveContextMenuStripAttribute
                                        $nodes = $xml.SelectNodes('//*')
                                        foreach ($node in $nodes) {
                                            $nodes.RemoveAttribute('ContextMenuStrip')
                                        }
                                        #brandoncomputer_ControlDirectReference
                                        #						$scriptText.Add("	`$$name.Add_$($_)({
		
                                        #})")#$scriptText.Add("        `$Script:refs['$($name)'].Add_$($_)(`$eventSB['$($name)'].$($_))")}
	
                                    }		
                                }
                            }
                            #brandoncomputer_FastTextScriptTextAdd
                            $fastArr = ($FastText.Text).split([byte][char]13 + [byte][char]10)
                            foreach ($arrItem in $fastArr) {
                                $scriptText.Add($arrItem)
                            }
								
                            #brandoncomputer_Uhh....
                            #$scriptText.Add($controlScriptInit)

                            $Script:templateText.EndRegion_Events.ForEach({ $scriptText.Add($_) })
                            

                            # Other Actions Before ShowDialog
                            $Script:templateText.Region_OtherActions.ForEach({ $scriptText.Add($_) })
                            #brandoncomputer_NotSure
                            $scriptText.Add("    try {[void]`$Script:refs['$($xml.Data.Form.Name)'].ShowDialog()} catch {Update-ErrorLog -ErrorRecord `$_ -Message `"Exception encountered unexpectedly at ShowDialog.`"}")
                            $scriptText.Add("")

                            # Actions After Form Closed
                            $Script:templateText.Region_AfterClose_EndSTAScriptBlock.ForEach({ $scriptText.Add($_) })

                            # Start Point of Execution (Runspace Setup)
                            $Script:templateText.Region_StartPoint.ForEach({ $scriptText.Add($_) })

                            # Split Dot Sourced code to separate files
                            #brandoncomputer_AddWarning
                            $ask = [System.Windows.Forms.MessageBox]::Show("Overwrite previous exports?", 'Confirm', 4) 
                            if ( $Script:refsGenerate['gbx_DotSource'].Controls.Checked -contains $true ) {
                                $Script:refsGenerate['gbx_DotSource'].Controls.Where({ $_.Checked -eq $true }) | ForEach-Object {
                                    $regionName = switch ($_.Name) {
                                        cbx_Functions { 'Functions' }
                                        cbx_Events { 'Event ScriptBlocks' }
                                        cbx_ChildForms { 'Child Forms' }
                                        cbx_ReuseContext { 'Reusable ContextMenuStrips' }
                                        cbx_EnvSetup { 'Environment Setup' }
                                        cbx_Timers { 'Timers' }
                                        cbx_Dialogs { 'Dialogs' }
                                    }

                                    $startIndex = [array]::IndexOf($scriptText, "    #region $($regionName)")
                                    $endIndex = [array]::IndexOf($scriptText, "    #endregion $($regionName)")
                                    if ($ask -eq 'Yes') {
                                        $scriptText[$startIndex..$endIndex] | Out-File "$($generationPath)\$($Script:refsGenerate['gbx_DotSource'].Controls[$($_.Name -replace "^c",'t')].Text)"
                                    }
                                    $afterText = $scriptText[($endIndex + 2)..($scriptText.Count - 1)]
                                    $scriptText = $scriptText[0..($startIndex - 1)]
                                    $scriptText += $afterText
                                }
                            
                            }
							
                            $ascii = new-object System.Text.ASCIIEncoding
                            $FastText.SaveToFile("$generationPath\Events.ps1", $ascii)
                            $scriptText | Out-File "$($generationPath)\$($projectName -replace "fbs$","ps1")" -Encoding ASCII -Force

                            $Script:refs['tsl_StatusLabel'].text = 'Script file(s) successfully generated!'
                        }
                    }
                    catch {
                        if ( $_.Exception.Message -ne 'SaveCancelled' ) {
                            $Script:refs['tsl_StatusLabel'].text = 'There was an issue generating the script file.'
                            Update-ErrorLog -ErrorRecord $_
                        }
                    }
                }
            }
        }
        'TreeView'             = @{
            AfterSelect = {
                if ( $Script:openingProject -eq $false ) {
                    try {
                        $objRef = Get-RootNodeObjRef -TreeNode $this.SelectedNode
                        $nodeName = $this.SelectedNode.Name
                        $nodeType = $this.SelectedNode.Text -replace " - .*$"

                        $Script:refs['PropertyGrid'].SelectedObject = $objRef.Objects[$nodeName]

                        if ( $objRef.Objects[$nodeName].Parent ) {
                            
                            if (( @('FlowLayoutPanel', 'TableLayoutPanel') -notcontains $objRef.Objects[$nodeName].Parent.GetType().Name ) -and
                               ( $objRef.Objects[$nodeName].Dock -eq 'None' ) -and
                               ( @('SplitterPanel', 'ToolStripMenuItem', 'ToolStripComboBox', 'ToolStripTextBox', 'ToolStripSeparator', 'ContextMenuStrip') -notcontains $nodeType ) -and
                               ( $Script:supportedControls.Where({ $_.Type -eq 'Parentless' }).Name -notcontains $nodeType )) {
                                
                                $objRef.Objects[$nodeName].BringToFront()
                            }
                            #  if ($DPI -ne 'dpi'){
                            Move-SButtons -Object $objRef.Objects[$nodeName]
                            #}
                        }
                        else { $Script:sButtons.GetEnumerator().ForEach({ $_.Value.Visible = $false }) }

                        $Script:refs['lst_AssignedEvents'].Items.Clear()

                        if ( $objRef.Events[$this.SelectedNode.Name] ) {
                            $Script:refs['lst_AssignedEvents'].BeginUpdate()
                            $objRef.Events[$nodeName].ForEach({ [void]$Script:refs['lst_AssignedEvents'].Items.Add($_) })
                            $Script:refs['lst_AssignedEvents'].EndUpdate()

                            $Script:refs['lst_AssignedEvents'].Enabled = $true
                        }
                        else {
                            $Script:refs['lst_AssignedEvents'].Items.Add('No Events')
                            $Script:refs['lst_AssignedEvents'].Enabled = $false
                        }

                        $eventTypes = $($Script:refs['PropertyGrid'].SelectedObject | Get-Member -Force).Name -match "^add_"

                        $Script:refs['lst_AvailableEvents'].Items.Clear()
                        $Script:refs['lst_AvailableEvents'].BeginUpdate()

                        if ( $eventTypes.Count -gt 0 ) {
                            $eventTypes | ForEach-Object { [void]$Script:refs['lst_AvailableEvents'].Items.Add("$($_ -replace "^add_")") }
                        }
                        else {
                            [void]$Script:refs['lst_AvailableEvents'].Items.Add('No Events Found on Selected Object')
                            $Script:refs['lst_AvailableEvents'].Enabled = $false
                        }

                        $Script:refs['lst_AvailableEvents'].EndUpdate()
                    }
                    catch { Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered after selecting TreeNode." }
                }
            }
        }
        'PropertyGrid'         = @{
            PropertyValueChanged = {
                param($Sender, $e)
				
				
				
                try {
                    $changedProperty = $e.ChangedItem
					
                    if ( @('Location', 'Size', 'Dock', 'AutoSize', 'Multiline') -contains $changedProperty.PropertyName ) { Move-SButtons -Object $Script:refs['PropertyGrid'].SelectedObject }
                    
                    if ( $e.ChangedItem.PropertyDepth -gt 0 ) {
                        $stopProcess = $false
                        ($e.ChangedItem.PropertyDepth - 1)..0 | ForEach-Object {
                            if ( $stopProcess -eq $false ) {
                                if ( $changedProperty.ParentGridEntry.HelpKeyword -match "^System.Windows.Forms.SplitContainer.Panel" ) {
                                    $stopProcess = $true
                                    $value = $changedProperty.GetPropertyTextValue()
                                    $Script:refs['TreeView'].SelectedNode = $objRefs.Form.TreeNodes["$($Script:refs['TreeView'].SelectedNode.Name)_$($changedProperty.ParentGridEntry.HelpKeyword.Split('.')[-1])"]
                                }
                                else {
                                    $changedProperty = $changedProperty.ParentGridEntry
                                    $value = $changedProperty.GetPropertyTextValue()
                                }
                            }
                        }
                    }
                    else { $value = $changedProperty.GetPropertyTextValue() }

                    $changedControl = $Script:refs['PropertyGrid'].SelectedObject
                    $controlType = $Script:refs['TreeView'].SelectedNode.Text -replace " - .*$"
                    $controlName = $Script:refs['TreeView'].SelectedNode.Name

                    $objRef = Get-RootNodeObjRef -TreeNode $Script:refs['TreeView'].SelectedNode

                    if ( $changedProperty.PropertyDescriptor.ShouldSerializeValue($changedProperty.Component) ) {
						
                        switch ($changedProperty.PropertyType) {
                            'System.Drawing.Image' {
                                $MemoryStream = New-Object System.IO.MemoryStream
                                $Script:refsFID.Form.Objects[$controlName].($changedProperty.PropertyName).save($MemoryStream, [System.Drawing.Imaging.ImageFormat]::Jpeg)
                                $Bytes = $MemoryStream.ToArray()
                                $MemoryStream.Flush()
                                $MemoryStream.Dispose()
                                $decodedimage = [convert]::ToBase64String($Bytes)

                                if ($FastText.GetLineText(0) -eq "#region Images") {
                                    $FastText.ExpandFoldedBlock(0)
                                    $FastText.SelectionStart = 16
                                }

                                $string = "`$$controlName.$($changedProperty.PropertyName) = [System.Drawing.Image]::FromStream([System.IO.MemoryStream][System.Convert]::FromBase64String(`"$decodedimage`"))
"
                                $FastText.SelectedText = $string

                                if ($FastText.GetLineText(0) -eq "#region Images") {
                                    $FastText.CollapseFoldingBlock(0)
                                }
							
                            }
							
                            'System.Drawing.Icon' {
                                $MemoryStream = New-Object System.IO.MemoryStream
                                $Script:refsFID.Form.Objects[$controlName].Icon.save($MemoryStream)
                                $Bytes = $MemoryStream.ToArray()
                                $MemoryStream.Flush()
                                $MemoryStream.Dispose()
                                $decodedimage = [convert]::ToBase64String($Bytes)

                                if ($FastText.GetLineText(0) -eq "#region Images") {
                                    $FastText.ExpandFoldedBlock(0)
                                    $FastText.SelectionStart = 16
                                }
								
                                $string = "`$$controlName.Icon = [System.Drawing.Icon]::FromHandle(([System.Drawing.Bitmap][System.Drawing.Image]::FromStream([System.IO.MemoryStream][System.Convert]::FromBase64String(`"$decodedimage`"))).GetHicon())
"
                                $FastText.SelectedText = $string
					
                                if ($FastText.GetLineText(0) -eq "#region Images") {
                                    $FastText.CollapseFoldingBlock(0)
                                }
						

								
                            }
							
                            default {
                                if ( $null -eq $objRef.Changes[$controlName] ) { $objRef.Changes[$controlName] = @{} }
                                $objRef.Changes[$controlName][$changedProperty.PropertyName] = $value
                            }
                        }

                    }
                    elseif ( $objRef.Changes[$controlName] ) {
                        if ( $objRef.Changes[$controlName][$changedProperty.PropertyName] ) {
                            $objRef.Changes[$controlName].Remove($changedProperty.PropertyName)
                            if ( $objRef.Changes[$controlName].Count -eq 0 ) { $objRef.Changes.Remove($controlName) }
                        }
                    }
                }
                catch { Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered after changing property value ($($controlType) - $($controlName))." }
            }
        }
        'trv_Controls'         = @{
            DoubleClick = {
                $controlName = $this.SelectedNode.Name
				
				
                switch ($controlName) {
                    'MenuStrip' {
                        $Script:refs['tsl_StatusLabel'].text = "Please do not use item collections in the property grid. Build onto controls by stacking controls from the selection on the left."
                    }
                    'ContextMenuStrip' {
                        $Script:refs['tsl_StatusLabel'].text = "Please do not use item collections in the property grid. Build onto controls by stacking controls from the selection on the left."
                    }
                    'StatusStrip' {
                        $Script:refs['tsl_StatusLabel'].text = "Please do not use item collections in the property grid. Build onto controls by stacking controls from the selection on the left."
                    }
                    'ToolStrip' {
                        $Script:refs['tsl_StatusLabel'].text = "Please do not use item collections in the property grid. Build onto controls by stacking controls from the selection on the left."
                    }
                    'ToolStripDropDownButton' {
                        $Script:refs['tsl_StatusLabel'].text = "Please do not use item collections in the property grid. Build onto controls by stacking controls from the selection on the left."
                    }
                    'ToolStripSplitButton' {
                        $Script:refs['tsl_StatusLabel'].text = "Please do not use item collections in the property grid. Build onto controls by stacking controls from the selection on the left."
                    }
                    'ToolStripMenuItem' {
                        $Script:refs['tsl_StatusLabel'].text = "Please do not use item collections in the property grid. Build onto controls by stacking controls from the selection on the left."
                    }
                    default {}
                }

                if ( $controlName -eq 'ContextMenuStrip' ) {
                    #brandoncomputer_RemoveGlobalContextMenuStrip
                    $context = 1
                }
                else { $context = 2 }

                if ( @('All Controls', 'Common', 'Containers', 'Menus and ToolStrips', 'Miscellaneous') -notcontains $controlName ) {
                    $controlObjectType = $Script:supportedControls.Where({ $_.Name -eq $controlName }).Type
					

                    
                    try {
                        if (( $controlObjectType -eq 'Parentless' ) -or ( $context -eq 0 )) {
                            $controlType = $controlName
                            #brandoncomputer_autoname&autotext
                            $Script:newNameCheck = $false
                            #    $userInput = Get-UserInputFromForm -SetText "$($Script:supportedControls.Where({$_.Name -eq $controlType}).Prefix)_"
                            $Script:newNameCheck = $true
							
                            #   if ( $userInput.Result -eq 'OK' ) {
                            if ( $Script:refs['TreeView'].Nodes.Text -match "$($controlType) - $($userInput.NewName)" ) {
                                [void][System.Windows.Forms.MessageBox]::Show("A $($controlType) with the Name '$($userInput.NewName)' already exists.", 'Error')
                            }
                            else {
                                #  Add-TreeNode -TreeObject $Script:refs['TreeView'] -ControlType $controlType -ControlName $userInput.NewName
                                if ($control_track.$controlName -eq $null) {
                                    $control_track[$controlName] = 1
                                }
                                else {
                                    $control_track.$controlName = $control_track.$controlName + 1
                                }
                                #	info "$($controlType) - $controlName$($control_track.$controlName)"
                                if ( $Script:refs['TreeView'].Nodes.Text -match "$($controlType) - $controlName$($control_track.$controlName)" )
                                { [void][System.Windows.Forms.MessageBox]::Show("A $($controlType) with the Name '$controlName$($control_track.$controlName)' already exists.", 'Error') }
                                else {
                                    Add-TreeNode -TreeObject $Script:refs['TreeView'] -ControlType $controlName "$controlName$($control_track.$controlName)" "$controlName$($control_track.$controlName)"
                                }
                            }
                            #   }
                        }
                        else {
                            if ( $Script:supportedControls.Where({ $_.Name -eq $($refs['TreeView'].SelectedNode.Text -replace " - .*$") }).ChildTypes -contains $controlObjectType ) {
                                if ($control_track.$controlName -eq $null) {
                                    $control_track[$controlName] = 1
                                }
                                else {
                                    $control_track.$controlName = $control_track.$controlName + 1
                                }

                                if ($Script:refs['TreeView'].Nodes.Nodes | Where-Object { $_.Text -eq "$($controlName) - $controlName$($control_track.$controlName)" })
                                { [void][System.Windows.Forms.MessageBox]::Show("A $($controlName) with the Name '$controlName$($control_track.$controlName)' already exists. Try again to create '$controlName$($control_track.$controlName + 1)'", 'Error') }
                                else {
                                    Add-TreeNode -TreeObject $Script:refs['TreeView'].SelectedNode -ControlType $controlName "$controlName$($control_track.$controlName)" "$controlName$($control_track.$controlName)"
                                }
                            }
                            else {


                                if ($control_track.$controlName -eq $null) {
                                    $control_track[$controlName] = 1
                                }
                                else {
                                    $control_track.$controlName = $control_track.$controlName + 1
                                }
                                #brandoncomputer_SlickToTopNode
								
                                if ($Script:refs['TreeView'].Nodes.Nodes | Where-Object { $_.Text -eq "$($controlName) - $controlName$($control_track.$controlName)" })
                                { [void][System.Windows.Forms.MessageBox]::Show("A $($controlName) with the Name '$controlName$($control_track.$controlName)' already exists. Try again to create '$controlName$($control_track.$controlName + 1)'", 'Error') }
                                else {
                                    Add-TreeNode -TreeObject $Script:refs['TreeView'].TopNode -ControlType $controlName "$controlName$($control_track.$controlName)" "$controlName$($control_track.$controlName)"
                                }
                                #[void][System.Windows.Forms.MessageBox]::Show("Unable to add $($controlName) to $($refs['TreeView'].SelectedNode.Text -replace " - .*$").")
                            }
                        }
                    }
                    catch {
                        Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered while adding '$($controlName)'."
                    } 
                }
            }
        }
		
		
        'lst_AvailableEvents'  = @{
            DoubleClick = {
                $controlName = $Script:refs['TreeView'].SelectedNode.Name
                $objRef = Get-RootNodeObjRef -TreeNode $Script:refs['TreeView'].SelectedNode

                if ( $Script:refs['lst_AssignedEvents'].Items -notcontains $this.SelectedItem ) {
                    if ( $Script:refs['lst_AssignedEvents'].Items -contains 'No Events' ) { $Script:refs['lst_AssignedEvents'].Items.Clear() }
                    [void]$Script:refs['lst_AssignedEvents'].Items.Add($this.SelectedItem)
                    $Script:refs['lst_AssignedEvents'].Enabled = $true

                    $objRef.Events[$controlName] = @($Script:refs['lst_AssignedEvents'].Items)
					
                    #brandoncomputer_AddEventtoFastText
                    $FastText.GoEnd()
                    $FastText.SelectedText = "`$$ControlName.add_$($this.SelectedItem)({param(`$sender, `$e)
	
})

"
					
                }
            }
        }
        'lst_AssignedEvents'   = @{
            DoubleClick = {
                $controlName = $Script:refs['TreeView'].SelectedNode.Name
                $objRef = Get-RootNodeObjRef -TreeNode $Script:refs['TreeView'].SelectedNode

                $Script:refs['lst_AssignedEvents'].Items.Remove($this.SelectedItem)
				
                if ( $Script:refs['lst_AssignedEvents'].Items.Count -eq 0 ) {
                    $Script:refs['lst_AssignedEvents'].Items.Add('No Events')
                    $Script:refs['lst_AssignedEvents'].Enabled = $false
                }

                if ( $Script:refs['lst_AssignedEvents'].Items[0] -ne 'No Events' ) {
                    $objRef.Events[$controlName] = @($Script:refs['lst_AssignedEvents'].Items)
                }
                else {
                    if ( $objRef.Events[$controlName] ) {
                        $objRef.Events.Remove($controlName)
                    }
                }
            }
        }
        'ChangeView'           = {
            try {
                switch ($this.Text) {
                    'Toolbox' {
                        $pnlChanged = $refs['pnl_Left']
                        $sptChanged = $refs['spt_Left']
                        $tsViewItem = $refs['Toolbox']
                        $tsMenuItem = $refs['ms_Toolbox']
                        $thisNum = '1'
                        $otherNum = '2'
                        $side = 'Left'
                    }
                    'Form Tree' {
                        $pnlChanged = $refs['pnl_Left']
                        $sptChanged = $refs['spt_Left']
                        $tsViewItem = $refs['FormTree']
                        $tsMenuItem = $refs['ms_FormTree']
                        $thisNum = '2'
                        $otherNum = '1'
                        $side = 'Left'
                    }
                    'Properties' {
                        $pnlChanged = $refs['pnl_Right']
                        $sptChanged = $refs['spt_Right']
                        $tsViewItem = $refs['Properties']
                        $tsMenuItem = $refs['ms_Properties']
                        $thisNum = '1'
                        $otherNum = '2'
                        $side = 'Right'
                    }
                    'Events' {
                        $pnlChanged = $refs['pnl_Right']
                        $sptChanged = $refs['spt_Right']
                        $tsViewItem = $refs['Events']
                        $tsMenuItem = $refs['ms_Events']
                        $thisNum = '2'
                        $otherNum = '1'
                        $side = 'Right'
                    }
                }
                #brandoncomputer_TabColorSchemeChange
                if (( $pnlChanged.Visible ) -and ( $sptChanged."Panel$($thisNum)Collapsed" )) {
                    $sptChanged."Panel$($thisNum)Collapsed" = $false
                    $tsViewItem.Checked = $true
                    $tsMenuItem.BackColor = 'RoyalBlue'
                }
                elseif (( $pnlChanged.Visible ) -and ( $sptChanged."Panel$($thisNum)Collapsed" -eq $false )) {
                    $tsViewItem.Checked = $false
                    $tsMenuItem.BackColor = 'MidnightBlue'

                    if ( $sptChanged."Panel$($otherNum)Collapsed" ) { $pnlChanged.Visible = $false } else { $sptChanged."Panel$($thisNum)Collapsed" = $true }
                }
                else {
                    $tsViewItem.Checked = $true
                    $tsMenuItem.BackColor = 'RoyalBlue'
                    $sptChanged."Panel$($thisNum)Collapsed" = $false
                    $sptChanged."Panel$($otherNum)Collapsed" = $true
                    $pnlChanged.Visible = $true
                }

                if ( $pnlChanged.Visible -eq $true ) { $refs["lbl_$($side)"].Visible = $true } else { $refs["lbl_$($side)"].Visible = $false }
            }
            catch { Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered during View change." }
        }
        'ChangePanelSize'      = @{
            'MouseMove' = {
                param($Sender, $e)
                
                if (( $e.Button -eq 'Left' ) -and ( $e.Location.X -ne 0 )) {
                    # Determine which panel to resize
                    $side = $Sender.Name -replace "^lbl_"
                    # Determine the new X coordinate
                    if ( $side -eq 'Right' ) { $newX = $refs["pnl_$($side)"].Size.Width - $e.Location.X } else { $newX = $refs["pnl_$($side)"].Size.Width + $e.Location.X }
                    # Change the size of the panel
                    if ( $newX -ge 100 ) { $refs["pnl_$($side)"].Size = New-Object System.Drawing.Size($newX, $refs["pnl_$($side)"].Size.Y) }
                    # Refresh form to remove artifacts while dragging
                    $Sender.Parent.Refresh()
                }
            }
        }
        'CheckedChanged'       = {
            param ($Sender)

            if ( $Sender.Checked ) {
                $Sender.Parent.Controls["$($Sender.Name -replace "^c",'t')"].Enabled = $true
                $Sender.Parent.Controls["$($Sender.Name -replace "^c",'t')"].Focus()
            }
            else { $Sender.Parent.Controls["$($Sender.Name -replace "^c",'t')"].Enabled = $false }
        }
    }

    #endregion Event ScriptBlocks

    #region Child Forms

    $Script:childFormInfo = @{
        'NameInput' = @{
            XMLText = @"
  <Form Name="NameInput" ShowInTaskbar="False" MaximizeBox="False" Text="Enter Name" Size="700, 125" StartPosition="CenterParent" MinimizeBox="False" BackColor="171, 171, 171" FormBorderStyle="FixedDialog" Font="Arial, 18pt">
    <Label Name="label" TextAlign="MiddleCenter" Location="25, 25" Size="170, 40" Text="Control Name:" />
    <TextBox Name="UserInput" Location="210, 25" Size="425, 25"/>
    <Button Name="StopDingOnEnter" Visible="False" />
  </Form>
"@
            Events  = @(
                [pscustomobject]@{
                    Name        = 'NameInput'
                    EventType   = 'Activated'
                    #brandoncomputer_FixControlInput
                    ScriptBlock = { $this.Controls['UserInput'].Focus()
                        $this.Controls['UserInput'].Select(5, 0) }
                },
                [pscustomobject]@{
                    Name        = 'UserInput'
                    EventType   = 'KeyUp'
                    ScriptBlock = {
                        if ( $_.KeyCode -eq 'Return' ) {
                            $objRef = Get-RootNodeObjRef -TreeNode $Script:refs['TreeView'].SelectedNode

                            if ( $((Get-Date) - $($Script:lastUIKeyUp)).TotalMilliseconds -lt 250 ) {
                                # Do nothing
                            }
                            elseif ( $this.Text -match "(\||<|>|&|\$|'|`")" ) {
                                [void][System.Windows.Forms.MessageBox]::Show("Names cannot contain any of the following characters: `"|<'>`"&`$`".", 'Error')
                            }
                            elseif (( $objref.TreeNodes[$($this.Text.Trim())] ) -and ( $Script:newNameCheck -eq $true )) {
                                [void][System.Windows.Forms.MessageBox]::Show("All elements must have unique names for this application to function as intended. The name '$($this.Text.Trim())' is already assigned to another element.", 'Error')
                            }
                            elseif ( $($this.Text -replace "\s") -eq '' ) {
                                [void][System.Windows.Forms.MessageBox]::Show("All elements must have names for this application to function as intended.", 'Error')
                                $this.Text = ''
                            }
                            else {
                                $this.Parent.DialogResult = 'OK'
                                $this.Text = $this.Text.Trim()
                                $this.Parent.Close()
                            }

                            $Script:lastUIKeyUp = Get-Date
                        }
                    }
                }
            )
        }
        #brandoncomputer_ChangeExports
        'Generate'  = @{
            XMLText = @"
  <Form Name="Generate" FormBorderStyle="FixedDialog" MaximizeBox="False" MinimizeBox="False" ShowIcon="False" ShowInTaskbar="False" Size="410, 420" StartPosition="CenterParent" Text="Generate Script File(s)">
    <GroupBox Name="gbx_DotSource" Location="25, 115" Size="345, 219" Text="Dot Sourcing">
      <CheckBox Name="cbx_Functions" Location="25, 25" Text="Functions" Checked="True" />
      <TextBox Name="tbx_Functions" Enabled="True" Location="165, 25" Size="150, 20" Text="Functions.ps1" />
      <CheckBox Name="cbx_Events" Location="25, 55" Text="Events" Checked="True" />
      <TextBox Name="tbx_Events" Enabled="True" Location="165, 55" Size="150, 20" Text="Events.ps1" />
      <CheckBox Name="cbx_ChildForms" Location="25, 85" Text="Child Forms" />
      <TextBox Name="tbx_ChildForms" Enabled="False" Location="165, 85" Size="150, 20" Text="ChildForms.ps1" />
      <CheckBox Name="cbx_Timers" Location="25, 115" Text="Timers" />
      <TextBox Name="tbx_Timers" Enabled="False" Location="165, 115" Size="150, 20" Text="Timers.ps1" />
      <CheckBox Name="cbx_Dialogs" Location="25, 145" Text="Dialogs" />
      <TextBox Name="tbx_Dialogs" Enabled="False" Location="165, 145" Size="150, 20" Text="Dialogs.ps1" />
      <CheckBox Name="cbx_ReuseContext" Location="25, 175" Size="134, 24" Text="Reuse ContextStrips" Visible="False" />
      <TextBox Name="tbx_ReuseContext" Enabled="False" Location="165, 175" Size="150, 20" Text="ReuseContext.ps1" Visible="False" />
      <CheckBox Name="cbx_EnvSetup" Location="25, 175" Size="134, 24" Text="Environment Setup" />
      <TextBox Name="tbx_EnvSetup" Enabled="False" Location="165, 175" Size="150, 20" Text="EnvSetup.ps1" />
    </GroupBox>
    <GroupBox Name="gbx_ChildForms" Location="25, 25" Size="345, 65" Text="Child Forms">
      <Button Name="btn_Add" FlatStyle="System" Font="Microsoft Sans Serif, 14.25pt, style=Bold" Location="25, 25" Size="21, 19" Text="+" />
      <TextBox Name="tbx_ChildForm1" Enabled="False" Location="62, 25" Size="252, 20" />
    </GroupBox>
    <Button Name="btn_Generate" FlatStyle="Flat" Location="104, 346" Size="178, 23" Text="Generate Script File(s)" />
  </Form>
"@
            Events  = @(
                [pscustomobject]@{
                    Name        = 'cbx_Functions'
                    EventType   = 'CheckedChanged'
                    ScriptBlock = $Script:eventSB.CheckedChanged
                },
                [pscustomobject]@{
                    Name        = 'cbx_Events'
                    EventType   = 'CheckedChanged'
                    ScriptBlock = $Script:eventSB.CheckedChanged
                },
                [pscustomobject]@{
                    Name        = 'cbx_ChildForms'
                    EventType   = 'CheckedChanged'
                    ScriptBlock = $Script:eventSB.CheckedChanged
                },
                [pscustomobject]@{
                    Name        = 'cbx_Timers'
                    EventType   = 'CheckedChanged'
                    ScriptBlock = $Script:eventSB.CheckedChanged
                },
                [pscustomobject]@{
                    Name        = 'cbx_Dialogs'
                    EventType   = 'CheckedChanged'
                    ScriptBlock = $Script:eventSB.CheckedChanged
                },
                [pscustomobject]@{
                    Name        = 'cbx_ReuseContext'
                    EventType   = 'CheckedChanged'
                    ScriptBlock = $Script:eventSB.CheckedChanged
                },
                [pscustomobject]@{
                    Name        = 'cbx_EnvSetup'
                    EventType   = 'CheckedChanged'
                    ScriptBlock = $Script:eventSB.CheckedChanged
                },
                [pscustomobject]@{
                    Name        = 'btn_Add'
                    EventType   = 'Click'
                    ScriptBlock = {
                        $openDialog = ConvertFrom-WinFormsXML -Xml @"
<OpenFileDialog InitialDirectory="$($Script:projectsDir)" AddExtension="True" DefaultExt="fbs" Filter="fbs files (*.fbs)|*.fbs" FilterIndex="1" ValidateNames="True" CheckFileExists="True" RestoreDirectory="True" />
"@
                        $openDialog.Add_FileOK({
                                param($Sender, $e)

                                if ( $Script:refsGenerate['gbx_ChildForms'].Controls.Tag -contains $this.FileName ) {
                                    [void][System.Windows.Forms.MessageBox]::Show("The project '$($this.FileName | Split-Path -Leaf)' has already been added as a child form of this project.", 'Validation Error')
                                    $e.Cancel = $true
                                }
                            })

                        try {
                            if ( $openDialog.ShowDialog() -eq 'OK' ) {
                                $fileName = $openDialog.FileName

                                $childFormCount = $Script:refsGenerate['gbx_ChildForms'].Controls.Where({ $_.Name -match 'tbx_' }).Count

                                @('Generate', 'gbx_ChildForms').ForEach({
                                        $Script:refsGenerate[$_].Size = New-Object System.Drawing.Size($Script:refsGenerate[$_].Size.Width, ($Script:refsGenerate[$_].Size.Height + 40))
                                    })

                                @('btn_Add', 'gbx_DotSource', 'btn_Generate').ForEach({
                                        $Script:refsGenerate[$_].Location = New-Object System.Drawing.Size($Script:refsGenerate[$_].Location.X, ($Script:refsGenerate[$_].Location.Y + 40))
                                    })

                                $Script:refsGenerate['Generate'].Location = New-Object System.Drawing.Size($Script:refsGenerate['Generate'].Location.X, ($Script:refsGenerate['Generate'].Location.Y - 20))

                                $defaultTextBox = $Script:refsGenerate['gbx_ChildForms'].Controls["tbx_ChildForm$($childFormCount)"]
                                $defaultTextBox.Location = New-Object System.Drawing.Size($defaultTextBox.Location.X, ($defaultTextBox.Location.Y + 40))
                                $defaultTextBox.Name = "tbx_ChildForm$($childFormCount + 1)"

                                $button = ConvertFrom-WinFormsXML -ParentControl $Script:refsGenerate['gbx_ChildForms'] -Xml @"
<Button Name="btn_Minus$($childFormCount)" Font="Microsoft Sans Serif, 14.25pt, style=Bold" FlatStyle="System" Location="25, $(25 + ($childFormCount - 1) * 40)" Size="21, 19" Text="-" />
"@
                                $button.Add_Click({
                                        try {
                                            [int]$btnIndex = $this.Name -replace "\D"
                                            $childFormCount = $Script:refsGenerate['gbx_ChildForms'].Controls.Where({ $_.Name -match 'tbx_' }).Count

                                            $($Script:refsGenerate['gbx_ChildForms'].Controls["tbx_ChildForm$($btnIndex)"]).Dispose()
                                            $this.Dispose()

                                            @(($btnIndex + 1)..$childFormCount).ForEach({
                                                    if ( $null -eq $Script:refsGenerate['gbx_ChildForms'].Controls["btn_Minus$($_)"] ) { $btnName = 'btn_Add' } else { $btnName = "btn_Minus$($_)" }

                                                    $btnLocX = $Script:refsGenerate['gbx_ChildForms'].Controls[$btnName].Location.X
                                                    $btnLocY = $Script:refsGenerate['gbx_ChildForms'].Controls[$btnName].Location.Y

                                                    $Script:refsGenerate['gbx_ChildForms'].Controls[$btnName].Location = New-Object System.Drawing.Size($btnLocX, ($btnLocY - 40))

                                                    $tbxName = "tbx_ChildForm$($_)"

                                                    $tbxLocX = $Script:refsGenerate['gbx_ChildForms'].Controls[$tbxName].Location.X
                                                    $tbxLocY = $Script:refsGenerate['gbx_ChildForms'].Controls[$tbxName].Location.Y
                                                    $Script:refsGenerate['gbx_ChildForms'].Controls[$tbxName].Location = New-Object System.Drawing.Size($tbxLocX, ($tbxLocY - 40))

                                                    if ( $btnName -ne 'btn_Add' ) { $Script:refsGenerate['gbx_ChildForms'].Controls[$btnName].Name = "btn_Minus$($_ - 1)" }
                                                    $Script:refsGenerate['gbx_ChildForms'].Controls[$tbxName].Name = "tbx_ChildForm$($_ - 1)"
                                                })

                                            @('Generate', 'gbx_ChildForms').ForEach({
                                                    $Script:refsGenerate[$_].Size = New-Object System.Drawing.Size($Script:refsGenerate[$_].Size.Width, ($Script:refsGenerate[$_].Size.Height - 40))
                                                })

                                            @('gbx_DotSource', 'btn_Generate').ForEach({
                                                    $Script:refsGenerate[$_].Location = New-Object System.Drawing.Size($Script:refsGenerate[$_].Location.X, ($Script:refsGenerate[$_].Location.Y - 40))
                                                })

                                            $Script:refsGenerate['Generate'].Location = New-Object System.Drawing.Size($Script:refsGenerate['Generate'].Location.X, ($Script:refsGenerate['Generate'].Location.Y + 20))

                                            if ( $Script:refsGenerate['gbx_ChildForms'].Controls.Count -le 2 ) {
                                                $Script:refsGenerate['cbx_ChildForms'].Checked = $false
                                                $Script:refsGenerate['cbx_ChildForms'].Enabled = $false
                                            }

                                            Remove-Variable -Name btnIndex, childFormCount, btnName, btnLocX, btnLocY, tbxName, tbxLocX, tbxLocY
                                        }
                                        catch { Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered while removing child form." }
                                    })

                                ConvertFrom-WinFormsXML -ParentControl $Script:refsGenerate['gbx_ChildForms'] -Suppress -Xml @"
<TextBox Name="tbx_ChildForm$($childFormCount)" Location="62, $(25 + ($childFormCount - 1) * 40)" Size="252, 20" Text="...\$($fileName | Split-Path -Leaf)" Tag="$fileName" Enabled="False" />
"@
                                $Script:refsGenerate['cbx_ChildForms'].Enabled = $true
                                Remove-Variable -Name button, fileName, childFormCount, defaultTextBox
                            }
                        }
                        catch { Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered while adding child form." }
                        finally {
                            $openDialog.Dispose()
                            Remove-Variable -Name openDialog
                        }
                    }
                },
                [pscustomobject]@{
                    Name        = 'btn_Generate'
                    EventType   = 'Click'
                    ScriptBlock = {
                        #brandoncomputer_CreateBackup(Removed)
                        #$backup = "$(get-date -format 'yyyyMMddHHmm-dddd')"
                        #if ( (Test-Path -Path "$($generationPath)\$backup" -PathType Container) -eq $false ) {New-Item -Path "$($generationPath)\$backup" -ItemType Directory | Out-Null}
                        #  copy-item -path "$($generationPath)\*.*" -destination "$($generationPath)\$backup"
                        $fileError = 0
                        [array]$checked = $Script:refsGenerate['gbx_DotSource'].Controls.Where({ $_.Checked -eq $true })

                        if ( $checked.Count -gt 0 ) {
                            $checked.ForEach({
                                    $fileName = $($Script:refsGenerate[$($_.Name -replace "^cbx", "tbx")]).Text
                                    if ( $($fileName -match ".*\...") -eq $false ) {
                                        [void][System.Windows.Forms.MessageBox]::Show("Filename not valid for the dot sourcing of $($_.Name -replace "^cbx_")")
                                        $fileError++
                                    }
                                })
                        }

                        if ( $fileError -eq 0 ) {
                            $Script:refsGenerate['Generate'].DialogResult = 'OK'
                            $Script:refsGenerate['Generate'].Visible = $false
                        }
                    }
                }
            )
        }
    }

    #endregion Child Forms

    #region Reuseable ContextMenuStrips

    $reuseContextInfo = @{
        'TreeNode' = @{
            XMLText = @"
  <ContextMenuStrip Name="TreeNode">
    <ToolStripMenuItem Name="MoveUp" ShortcutKeys="F9" Text="Move Up" ShortcutKeyDisplayString="F9"/>
    <ToolStripMenuItem Name="MoveDown" ShortcutKeys="F10" Text="Move Down" ShortcutKeyDisplayString="F10"/>
    <ToolStripSeparator Name="Sep1" />
    <ToolStripMenuItem Name="CopyNode" ShortcutKeys="Ctrl+C" Text="Copy" ShortcutKeyDisplayString="Ctrl+C" />
    <ToolStripMenuItem Name="PasteNode" ShortcutKeys="Ctrl+P" Text="Paste" ShortcutKeyDisplayString="Ctrl+P" />
    <ToolStripSeparator Name="Sep2" />
    <ToolStripMenuItem Name="Rename" ShortcutKeys="Ctrl+R" Text="Rename" ShortcutKeyDisplayString="Ctrl+R" />
    <ToolStripMenuItem Name="Delete" ShortcutKeys="Ctrl+D" Text="Delete" ShortcutKeyDisplayString="Ctrl+D" />
  </ContextMenuStrip>
"@
            Events  = @(
                [pscustomobject]@{
                    Name        = 'TreeNode'
                    EventType   = 'Opening'
                    ScriptBlock = {
                        $parentType = $Script:refs['TreeView'].SelectedNode.Text -replace " - .*$"
                        
                        if ( $parentType -eq 'Form' ) {
                            $this.Items['Delete'].Visible = $false
                            $this.Items['CopyNode'].Visible = $false
                            $isCopyVisible = $false
                        }
                        else {
                            $this.Items['Delete'].Visible = $true
                            $this.Items['CopyNode'].Visible = $true
                            $isCopyVisible = $true
                        }

                        if ( $Script:nodeClipboard ) {
                            $this.Items['PasteNode'].Visible = $true
                            $this.Items['Sep2'].Visible = $true
                        }
                        else {
                            $this.Items['PasteNode'].Visible = $false
                            $this.Items['Sep2'].Visible = $isCopyVisible
                        }
                    }
                },
                [pscustomobject]@{
                    Name        = 'MoveUp'
                    EventType   = 'Click'
                    ScriptBlock = $eventSB['Move Up'].Click
                },
                [pscustomobject]@{
                    Name        = 'MoveDown'
                    EventType   = 'Click'
                    ScriptBlock = $eventSB['Move Down'].Click
                },
                [pscustomobject]@{
                    Name        = 'CopyNode'
                    EventType   = 'Click'
                    ScriptBlock = $eventSB['CopyNode'].Click
                },
                [pscustomobject]@{
                    Name        = 'PasteNode'
                    EventType   = 'Click'
                    ScriptBlock = $eventSB['PasteNode'].Click
                },
                [pscustomobject]@{
                    Name        = 'Rename'
                    EventType   = 'Click'
                    ScriptBlock = $eventSB['Rename'].Click
                },
                [pscustomobject]@{
                    Name        = 'Delete'
                    EventType   = 'Click'
                    ScriptBlock = $eventSB['Delete'].Click
                }
            )
        }
    }

    #endregion

    #region Environment Setup

    $noIssues = $true

    try {
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing

        # Confirm SavedProjects directory exists and set SavedProjects directory
        $Script:projectsDir = ([Environment]::GetFolderPath("MyDocuments") + "\PowerShell Designer")
        if ( (Test-Path -Path "$($Script:projectsDir)") -eq $false ) { New-Item -Path "$($Script:projectsDir)" -ItemType Directory | Out-Null }

        # Set Misc Variables
        $Script:lastUIKeyUp = Get-Date
        $Script:newNameCheck = $true
        $Script:openingProject = $false
        $Script:MouseMoving = $false
        #brandoncomputer_Controls
        $Script:supportedControls = @(
            [pscustomobject]@{Name = 'Button'; Prefix = 'btn'; Type = 'Common'; ChildTypes = @('Context') },
            [pscustomobject]@{Name = 'CheckBox'; Prefix = 'cbx'; Type = 'Common'; ChildTypes = @('Context') },
            [pscustomobject]@{Name = 'CheckedListBox'; Prefix = 'clb'; Type = 'Common'; ChildTypes = @('Context') },
            [pscustomobject]@{Name = 'ColorDialog'; Prefix = 'cld'; Type = 'Parentless'; ChildTypes = @() },
            [pscustomobject]@{Name = 'ComboBox'; Prefix = 'cmb'; Type = 'Common'; ChildTypes = @('Context') },
            [pscustomobject]@{Name = 'ContextMenuStrip'; Prefix = 'cms'; Type = 'Context'; ChildTypes = @('MenuStrip-Root', 'MenuStrip-Child') },
            [pscustomobject]@{Name = 'DataGrid'; Prefix = 'dgr'; Type = 'Common'; ChildTypes = @('Context') },
            [pscustomobject]@{Name = 'DataGridView'; Prefix = 'dgv'; Type = 'Common'; ChildTypes = @('Context') },
            [pscustomobject]@{Name = 'DateTimePicker'; Prefix = 'dtp'; Type = 'Common'; ChildTypes = @('Context') },
            [pscustomobject]@{Name = 'FlowLayoutPanel'; Prefix = 'flp'; Type = 'Container'; ChildTypes = @('Common', 'Container', 'MenuStrip', 'Context') },
            [pscustomobject]@{Name = 'FolderBrowserDialog'; Prefix = 'fbd'; Type = 'Parentless'; ChildTypes = @() },
            [pscustomobject]@{Name = 'FontDialog'; Prefix = 'fnd'; Type = 'Parentless'; ChildTypes = @() },
            [pscustomobject]@{Name = 'GroupBox'; Prefix = 'gbx'; Type = 'Container'; ChildTypes = @('Common', 'Container', 'MenuStrip', 'Context') },
            [pscustomobject]@{Name = 'Label'; Prefix = 'lbl'; Type = 'Common'; ChildTypes = @('Context') },
            [pscustomobject]@{Name = 'LinkLabel'; Prefix = 'llb'; Type = 'Common'; ChildTypes = @('Context') },
            [pscustomobject]@{Name = 'ListBox'; Prefix = 'lbx'; Type = 'Common'; ChildTypes = @('Context') },
            [pscustomobject]@{Name = 'ListView'; Prefix = 'lsv'; Type = 'Common'; ChildTypes = @('Context') }, # need to fix issue with VirtualMode when 0 items
            [pscustomobject]@{Name = 'MaskedTextBox'; Prefix = 'mtb'; Type = 'Common'; ChildTypes = @('Context') },
            [pscustomobject]@{Name = 'MenuStrip'; Prefix = 'mst'; Type = 'MenuStrip'; ChildTypes = @('MenuStrip-Root') },
            [pscustomobject]@{Name = 'MonthCalendar'; Prefix = 'mcd'; Type = 'Common'; ChildTypes = @('Context') },
            [pscustomobject]@{Name = 'NumericUpDown'; Prefix = 'nud'; Type = 'Common'; ChildTypes = @('Context') },
            [pscustomobject]@{Name = 'OpenFileDialog'; Prefix = 'ofd'; Type = 'Parentless'; ChildTypes = @() },
            [pscustomobject]@{Name = 'PageSetupDialog'; Prefix = 'psd'; Type = 'Parentless'; ChildTypes = @() },
            [pscustomobject]@{Name = 'Panel'; Prefix = 'pnl'; Type = 'Container'; ChildTypes = @('Common', 'Container', 'MenuStrip', 'Context') },
            [pscustomobject]@{Name = 'PictureBox'; Prefix = 'pbx'; Type = 'Common'; ChildTypes = @('Context') },
            [pscustomobject]@{Name = 'PrintDialog'; Prefix = 'prd'; Type = 'Parentless'; ChildTypes = @() },
            [pscustomobject]@{Name = 'PrintPreviewDialog'; Prefix = 'ppd'; Type = 'Parentless'; ChildTypes = @() },
            [pscustomobject]@{Name = 'ProgressBar'; Prefix = 'pbr'; Type = 'Common'; ChildTypes = @('Context') },
            [pscustomobject]@{Name = 'PropertyGrid'; Prefix = 'pgd'; Type = 'Common'; ChildTypes = @('Context') },
            [pscustomobject]@{Name = 'RadioButton'; Prefix = 'rdb'; Type = 'Common'; ChildTypes = @('Context') },
            [pscustomobject]@{Name = 'RichTextBox'; Prefix = 'rtb'; Type = 'Common'; ChildTypes = @('Context') },
            [pscustomobject]@{Name = 'SaveFileDialog'; Prefix = 'sfd'; Type = 'Parentless'; ChildTypes = @() },
            [pscustomobject]@{Name = 'SplitContainer'; Prefix = 'scr'; Type = 'Container'; ChildTypes = @('Context') },
            [pscustomobject]@{Name = 'SplitterPanel'; Prefix = 'spl'; Type = 'Container'; ChildTypes = @('Common', 'Container', 'MenuStrip', 'Context') },
            [pscustomobject]@{Name = 'StatusStrip'; Prefix = 'sta'; Type = 'MenuStrip'; ChildTypes = @('StatusStrip-Child', 'MenuStrip-Child', 'MenuStrip-Root') },
            [pscustomobject]@{Name = 'TabControl'; Prefix = 'tcl'; Type = 'Common'; ChildTypes = @('Context', 'TabControl') },
            [pscustomobject]@{Name = 'TabPage'; Prefix = 'tpg'; Type = 'TabControl'; ChildTypes = @('Common', 'Container', 'MenuStrip', 'Context') },
            [pscustomobject]@{Name = 'TableLayoutPanel'; Prefix = 'tlp'; Type = 'Container'; ChildTypes = @('Common', 'Container', 'MenuStrip', 'Context') },
            [pscustomobject]@{Name = 'TextBox'; Prefix = 'tbx'; Type = 'Common'; ChildTypes = @('Context') },
            [pscustomobject]@{Name = 'ToolStrip'; Prefix = 'tls'; Type = 'MenuStrip'; ChildTypes = @('MenuStrip-Root') },
            [pscustomobject]@{Name = 'ToolStripButton'; Prefix = 'tsb'; Type = 'MenuStrip-Root'; ChildTypes = @() },
            [pscustomobject]@{Name = 'ToolStripDropDownButton'; Prefix = 'tdd'; Type = 'MenuStrip-Root'; ChildTypes = @('MenuStrip-Root') },
            [pscustomobject]@{Name = 'ToolStripProgressBar'; Prefix = 'tpb'; Type = 'MenuStrip-Root'; ChildTypes = @() },
            [pscustomobject]@{Name = 'ToolStripSplitButton'; Prefix = 'tsp'; Type = 'MenuStrip-Root'; ChildTypes = @('MenuStrip-Root') },
            [pscustomobject]@{Name = 'ToolStripStatusLabel'; Prefix = 'tsl'; Type = 'StatusStrip-Child'; ChildTypes = @() },
            [pscustomobject]@{Name = 'Timer'; Prefix = 'tmr'; Type = 'Parentless'; ChildTypes = @() }, 
            [pscustomobject]@{Name = 'TrackBar'; Prefix = 'tbr'; Type = 'Common'; ChildTypes = @('Context') },
            [pscustomobject]@{Name = 'TreeView'; Prefix = 'tvw'; Type = 'Common'; ChildTypes = @('Context') },
            [pscustomobject]@{Name = 'WebBrowser'; Prefix = 'wbr'; Type = 'Common'; ChildTypes = @('Context') },
            [pscustomobject]@{Name = 'ToolStripMenuItem'; Prefix = 'tmi'; Type = 'MenuStrip-Root'; ChildTypes = @('MenuStrip-Root', 'MenuStrip-Child') },
            [pscustomobject]@{Name = 'ToolStripComboBox'; Prefix = 'tcb'; Type = 'MenuStrip-Root'; ChildTypes = @() },
            [pscustomobject]@{Name = 'ToolStripTextBox'; Prefix = 'ttb'; Type = 'MenuStrip-Root'; ChildTypes = @() },
            [pscustomobject]@{Name = 'ToolStripSeparator'; Prefix = 'tss'; Type = 'MenuStrip-Root'; ChildTypes = @() },
            [pscustomobject]@{Name = 'Form'; Prefix = 'frm'; Type = 'Special'; ChildTypes = @('Common', 'Container', 'Context', 'MenuStrip') }
        )

        $Script:specialProps = @{
            All          = @('(DataBindings)', 'FlatAppearance', 'Location', 'Size', 'AutoSize', 'Dock', 'TabPages', 'SplitterDistance', 'UseCompatibleTextRendering', 'TabIndex',
                'TabStop', 'AnnuallyBoldedDates', 'BoldedDates', 'Lines', 'Items', 'DropDownItems', 'Panel1', 'Panel2', 'Text', 'AutoCompleteCustomSource', 'Nodes')
            Before       = @('Dock', 'AutoSize')
            After        = @('SplitterDistance', 'AnnuallyBoldedDates', 'BoldedDates', 'Items', 'Text')
            BadReflector = @('UseCompatibleTextRendering', 'TabIndex', 'TabStop', 'IsMDIContainer')
            Array        = @('Items', 'AnnuallyBoldedDates', 'BoldedDates', 'MonthlyBoldedDates')
        }
    }
    catch {
        Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered during Environment Setup."
        $noIssues = $false
    }

    #endregion Environment Setup

    #region Secondary Control Initialization

    if ( $noIssues ) {
        try {
            Get-CustomControl -ControlInfo $reuseContextInfo['TreeNode'] -Reference reuseContext -Suppress
        }
        catch {
            Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered during Child Form Initialization."
            $noIssues = $false
        }
    }

    #endregion Secondary Control Initialization

    #region Main Form Initialization

    try {
        #brandoncomputer_FixWindowState
        ConvertFrom-WinFormsXML -Reference refs -Suppress -Xml @"
  <Form Name="MainForm" IsMdiContainer="True" Size="800,600" WindowState="Maximized" Text="PowerShell Designer">
    <TabControl Name="tcl_Top" Dock="Top" Size="10,20">
        <TabPage Name="tpg_Form1" Text="NewProject.fbs" />
    </TabControl>
    <Label Name="lbl_Left" Dock="Left" Cursor="VSplit" BackColor="35, 35, 35" Size="3, 737" />
    <Label Name="lbl_Right" Dock="Right" Cursor="VSplit" BackColor="35, 35, 35" Size="3, 737" />
    <Panel Name="pnl_Left" Dock="Left" BorderStyle="Fixed3D" Size="300, 737">
      <SplitContainer Name="spt_Left" Dock="Fill" Orientation="Horizontal" BackColor="ControlDark" SplitterDistance="300">
        <SplitterPanel Name="spt_Left_Panel1">
          <TreeView Name="trv_Controls" Dock="Fill" BackColor="Azure" />
        </SplitterPanel>
        <SplitterPanel Name="spt_Left_Panel2" BackColor="ControlLight">
          <TreeView Name="TreeView" Dock="Fill" BackColor="Azure" HideSelection="False" DrawMode="OwnerDrawText" />
        </SplitterPanel>
      </SplitContainer>
    </Panel>
    <Panel Name="pnl_Right" Dock="Right" BorderStyle="Fixed3D" Size="600, 737">
      <SplitContainer Name="spt_Right" Dock="Fill" BackColor="ControlDark" Orientation="Vertical" SplitterDistance="350">
        <SplitterPanel Name="spt_Right_Panel1">
          <PropertyGrid Name="PropertyGrid" ViewBackColor="Azure" Dock="Fill" />
        </SplitterPanel>
        <SplitterPanel Name="spt_Right_Panel2" BackColor="Control">
          <Label Name="lbl_AvailableEvents" TextAlign="BottomCenter" Anchor="Top, Left, Right" Size="300, 23" Text="Available Events" />
          <ListBox Name="lst_AvailableEvents" BackColor="Azure" Size="300, 125" Location="2, 30" Anchor="Top, Bottom, Left, Right" />
          <Label Name="lbl_AssignedEvents" Anchor="Bottom, Left, Right" Text="Assigned Events" Size="300, 23" TextAlign="BottomCenter" Location="0, 159" />
          <ListBox Name="lst_AssignedEvents" BackColor="Azure" Anchor="Bottom, Left, Right" Location="2, 191" Size="300, 108" />
        </SplitterPanel>
      </SplitContainer>
    </Panel>
    <MenuStrip Name="ms_Left" Dock="Left" AutoSize="False" BackColor="ControlDarkDark" LayoutStyle="VerticalStackWithOverflow" Size="23, 737" TextDirection="Vertical90" Font="Verdana, 9pt">
      <ToolStripMenuItem Name="ms_Toolbox" AutoSize="False" BackColor="RoyalBlue" ForeColor="AliceBlue" Size="23, 100" Text="Toolbox" />
      <ToolStripMenuItem Name="ms_FormTree" AutoSize="False" Text="Form Tree" Size="23, 100" TextDirection="Vertical90" BackColor="RoyalBlue" ForeColor="AliceBlue" TextAlign="MiddleLeft" />
    </MenuStrip>
    <MenuStrip Name="ms_Right" Dock="Right" AutoSize="False" BackColor="ControlDarkDark" LayoutStyle="VerticalStackWithOverflow" Size="23, 737" TextDirection="Vertical90" Font="Verdana, 9pt">
      <ToolStripMenuItem Name="ms_Properties" AutoSize="False" Text="Properties" Size="23, 100" TextDirection="Vertical270" BackColor="RoyalBlue" ForeColor="AliceBlue" TextAlign="MiddleLeft" />
      <ToolStripMenuItem Name="ms_Events" AutoSize="False" Size="23, 100" BackColor="RoyalBlue" ForeColor="AliceBlue" TextDirection="Vertical270" Text="Events" />
    </MenuStrip>
    <MenuStrip Name="MenuStrip" RenderMode="System">
      <ToolStripMenuItem Name="ts_File" DisplayStyle="Text" Text="File">
        <ToolStripMenuItem Name="New" ShortcutKeys="Ctrl+N" DisplayStyle="Text" ShortcutKeyDisplayString="Ctrl+N" Text="New" />
        <ToolStripMenuItem Name="Open" ShortcutKeys="Ctrl+O" DisplayStyle="Text" ShortcutKeyDisplayString="Ctrl+O" Text="Open" />
        <ToolStripMenuItem Name="Save" ShortcutKeys="Ctrl+S" DisplayStyle="Text" ShortcutKeyDisplayString="Ctrl+S" Text="Save" />
        <ToolStripMenuItem Name="Save As" ShortcutKeys="Ctrl+Alt+S" DisplayStyle="Text" ShortcutKeyDisplayString="Ctrl+Alt+S" Text="Save As" />
        <ToolStripSeparator Name="FileSep" DisplayStyle="Text" />
        <ToolStripMenuItem Name="Exit" ShortcutKeys="Ctrl+Alt+X" DisplayStyle="Text" ShortcutKeyDisplayString="Ctrl+Alt+X" Text="Exit" />
      </ToolStripMenuItem>
      <ToolStripMenuItem Name="ts_Edit" Text="Edit">
		<ToolStripMenuItem Name="Undo" ShortcutKeys="Ctrl+Z" Text="Undo" ShortcutKeyDisplayString="Ctrl+Z" />
		<ToolStripMenuItem Name="Redo" ShortcutKeys="Ctrl+Y" Text="Redo" ShortcutKeyDisplayString="Ctrl+Y" />
		<ToolStripSeparator Name="EditSep4" />
		<ToolStripMenuItem Name="Cut" ShortcutKeys="Ctrl+X" Text="Cut" ShortcutKeyDisplayString="Ctrl+X" />
		<ToolStripMenuItem Name="Copy" ShortcutKeys="Ctrl+C" Text="Copy" ShortcutKeyDisplayString="Ctrl+C" />
		<ToolStripMenuItem Name="Paste" ShortcutKeys="Ctrl+V" Text="Paste" ShortcutKeyDisplayString="Ctrl+V" />
		<ToolStripMenuItem Name="Select All" ShortcutKeys="Ctrl+A" Text="Select All" ShortcutKeyDisplayString="Ctrl+A" />		
		<ToolStripSeparator Name="EditSep5" />
		<ToolStripMenuItem Name="Find" ShortcutKeys="Ctrl+F" Text="Find" ShortcutKeyDisplayString="Ctrl+F" />
		<ToolStripMenuItem Name="Replace" ShortcutKeys="Ctrl+H" Text="Replace" ShortcutKeyDisplayString="Ctrl+H" />
		<ToolStripMenuItem Name="Goto" ShortcutKeys="Ctrl+G" Text="Go To Line..." ShortcutKeyDisplayString="Ctrl+G" />
		<ToolStripSeparator Name="EditSep6" />
		<ToolStripMenuItem Name="Collapse All" ShortcutKeys="F7" Text="Collapse All" ShortcutKeyDisplayString="F7" />
		<ToolStripMenuItem Name="Expand All" ShortcutKeys="F8" Text="Expand All" ShortcutKeyDisplayString="F8" />
	  </ToolStripMenuItem>
	  <ToolStripMenuItem Name="ts_Controls" Text="Controls">
        <ToolStripMenuItem Name="Rename" ShortcutKeys="Ctrl+R" Text="Rename" ShortcutKeyDisplayString="Ctrl+R" />
        <ToolStripMenuItem Name="Delete" ShortcutKeys="Ctrl+D" Text="Delete" ShortcutKeyDisplayString="Ctrl+D" />
        <ToolStripSeparator Name="EditSep1" />
        <ToolStripMenuItem Name="CopyNode" Text="Copy Control" />
        <ToolStripMenuItem Name="PasteNode" Text="Paste Control" />
        <ToolStripSeparator Name="EditSep2" />
        <ToolStripMenuItem Name="Move Up" ShortcutKeys="F9" Text="Move Up" ShortcutKeyDisplayString="F9" />
        <ToolStripMenuItem Name="Move Down" ShortcutKeys="F10" Text="Move Down" ShortcutKeyDisplayString="F10" />
	  </ToolStripMenuItem>
      <ToolStripMenuItem Name="ts_View" Text="View">
        <ToolStripMenuItem Name="Toolbox" Checked="True" Text="Toolbox"/>
        <ToolStripMenuItem Name="FormTree" Checked="True" DisplayStyle="Text" Text="Form Tree"/>
        <ToolStripMenuItem Name="Properties" Checked="True" DisplayStyle="Text" Text="Properties"/>
        <ToolStripMenuItem Name="Events" Checked="True" Text="Events"/>
      </ToolStripMenuItem>
      <ToolStripMenuItem Name="ts_Tools" DisplayStyle="Text" Text="Tools">
        <ToolStripMenuItem Name="Generate Script File" ShortcutKeys="F4" DisplayStyle="Text" Text="Generate Script File" ShortcutKeyDisplayString="F4" />
		<ToolStripMenuItem Name="RunLast" ShortcutKeys="F5" DisplayStyle="Text" Text="Save Events.ps1 and Run Last Generated" ShortcutKeyDisplayString="F5" />
      </ToolStripMenuItem>
    </MenuStrip>
	<StatusStrip Name="sta_Status">
      <ToolStripStatusLabel Name="tsl_StatusLabel" />
    </StatusStrip>
  </Form>
"@
    }
    catch { Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered during Form Initialization." }

    #endregion Form Initialization

    #region Event Assignment

    try {
        # Call to ScriptBlock
        $Script:refs['MainForm'].Add_FormClosing($eventSB['MainForm'].FormClosing)
        $Script:refs['MainForm'].Add_Load($eventSB['MainForm'].Load)
        $Script:refs['ms_Toolbox'].Add_Click($eventSB.ChangeView)
        $Script:refs['ms_FormTree'].Add_Click($eventSB.ChangeView)
        $Script:refs['ms_Properties'].Add_Click($eventSB.ChangeView)
        $Script:refs['ms_Events'].Add_Click($eventSB.ChangeView)
        $Script:refs['Toolbox'].Add_Click($eventSB.ChangeView)
        $Script:refs['FormTree'].Add_Click($eventSB.ChangeView)
        $Script:refs['Properties'].Add_Click($eventSB.ChangeView)
        $Script:refs['Events'].Add_Click($eventSB.ChangeView)
        $Script:refs['lbl_Left'].Add_MouseMove($eventSB.ChangePanelSize.MouseMove)
        $Script:refs['lbl_Right'].Add_MouseMove($eventSB.ChangePanelSize.MouseMove)
        $Script:refs['New'].Add_Click($eventSB['New'].Click)
        $Script:refs['Open'].Add_Click($eventSB['Open'].Click)
        $Script:refs['Rename'].Add_Click($eventSB['Rename'].Click)
        $Script:refs['Delete'].Add_Click($eventSB['Delete'].Click)
        $Script:refs['CopyNode'].Add_Click($eventSB['CopyNode'].Click)
        $Script:refs['PasteNode'].Add_Click($eventSB['PasteNode'].Click)
        $Script:refs['Move Up'].Add_Click($eventSB['Move Up'].Click)
        $Script:refs['Move Down'].Add_Click($eventSB['Move Down'].Click)
        $Script:refs['Generate Script File'].Add_Click($eventSB['Generate Script File'].Click)
        $Script:refs['TreeView'].Add_AfterSelect($eventSB['TreeView'].AfterSelect)
        $Script:refs['PropertyGrid'].Add_PropertyValueChanged($eventSB['PropertyGrid'].PropertyValueChanged)
		
		
		
        $Script:refs['trv_Controls'].Add_DoubleClick($eventSB['trv_Controls'].DoubleClick)
        $Script:refs['lst_AvailableEvents'].Add_DoubleClick($eventSB['lst_AvailableEvents'].DoubleClick)
        $Script:refs['lst_AssignedEvents'].Add_DoubleClick($eventSB['lst_AssignedEvents'].DoubleClick)
		
        $Script:refs['RunLast'].Add_Click({
                $projectName = $refs['tpg_Form1'].Text	
                if ($projectName -ne "NewProject.fbs") { 					
                    $generationPath = "$(Split-Path -Path $global:projectDirName)\$($projectName -replace "\..*$")"
                    if (Test-Path -path $generationPath) {
                        #do nothing
                    }
                    else {
                        New-Item -ItemType directory -Path $generationPath
                    }
                    $ascii = new-object System.Text.ASCIIEncoding
                    $FastText.SaveToFile("$generationPath\Events.ps1", $ascii)
                    $file = "`"$($generationPath)\$($projectName -replace "fbs$","ps1")`""

                    start-process -filepath powershell.exe -argumentlist '-ep bypass', '-sta', "-file $file"
                }
            })
		
        $Script:refs['Undo'].Add_Click({
                $FastText.Undo()
            })
		
        $Script:refs['Redo'].Add_Click({
                $FastText.Redo()
            })
		
        $Script:refs['Cut'].Add_Click({
                $FastText.Cut()
            })
		
        $Script:refs['Copy'].Add_Click({
                $FastText.Copy()
            })
		
        $Script:refs['Paste'].Add_Click({
                $FastText.Paste()
            })
		
        $Script:refs['Select All'].Add_Click({
                $FastText.SelectAll()
            })
		
        $Script:refs['Find'].Add_Click({
                $FastText.ShowFindDialog()
            })
		
        $Script:refs['Replace'].Add_Click({
                $FastText.ShowReplaceDialog()
            })
		
        $Script:refs['Goto'].Add_Click({
                $FastText.ShowGotoDialog()
            })
		
        $Script:refs['Expand All'].Add_Click({
                $FastText.ExpandAllFoldingBlocks()
            })
		
        $Script:refs['Collapse All'].Add_Click({
                $FastText.CollapseAllFoldingBlocks()
            })

        # ScriptBlock Here
        $Script:refs['Exit'].Add_Click({ $Script:refs['MainForm'].Close() })
        $Script:refs['Save'].Add_Click({ try { Save-Project } catch { if ( $_.Exception.Message -ne 'SaveCancelled' ) { throw $_ } } })
        $Script:refs['Save As'].Add_Click({ try { Save-Project -SaveAs } catch { if ( $_.Exception.Message -ne 'SaveCancelled' ) { throw $_ } } })
        $Script:refs['TreeView'].Add_DrawNode({ $args[1].DrawDefault = $true })
        $Script:refs['TreeView'].Add_NodeMouseClick({ $this.SelectedNode = $args[1].Node })
    }
    catch { Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered during Event Assignment." }

    #endregion Event Assignment

    #region Other Actions Before ShowDialog

    if ( $noIssues ) {
        try {
            @('All Controls', 'Common', 'Containers', 'Menus and ToolStrips', 'Miscellaneous').ForEach({
                    $treeNode = $Script:refs['trv_Controls'].Nodes.Add($_, $_)

                    switch ($_) {
                        'All Controls' { $Script:supportedControls.Where({ @('Special', 'SplitContainer') -notcontains $_.Type }).Name.ForEach({ $treeNode.Nodes.Add($_, $_) }) }
                        'Common' { $Script:supportedControls.Where({ $_.Type -eq 'Common' }).Name.ForEach({ $treeNode.Nodes.Add($_, $_) }) }
                        'Containers' { $Script:supportedControls.Where({ $_.Type -eq 'Container' }).Name.ForEach({ $treeNode.Nodes.Add($_, $_) }) }
                        'Menus and ToolStrips' { $Script:supportedControls.Where({ $_.Type -eq 'Context' -or $_.Type -match "^MenuStrip" -or $_.Type -match "Status*" -or $_.Type -eq "ToolStrip" }).Name.ForEach({ $treeNode.Nodes.Add($_, $_) }) }
                        'Miscellaneous' { $Script:supportedControls.Where({ @('TabControl', 'Parentless') -match "^$($_.Type)$" }).Name.ForEach({ $treeNode.Nodes.Add($_, $_) }) }
                    }
                })

            $Script:refs['trv_Controls'].Nodes.Where({ $_.Name -eq 'Common' }).Expand()

            [void]$Script:refs['lst_AssignedEvents'].Items.Add('No Events')
            $Script:refs['lst_AssignedEvents'].Enabled = $false

            # Add the Initial Form TreeNode
            Add-TreeNode -TreeObject $Script:refs['TreeView'] -ControlType Form -ControlName MainForm
			
            $Script:refsFID.Form.Objects[$($Script:refs['TreeView'].Nodes | Where-Object { $_.Text -match "^Form - " }).Name].height = $Script:refsFID.Form.Objects[$($Script:refs['TreeView'].Nodes | Where-Object { $_.Text -match "^Form - " }).Name].height * $tscale
            $Script:refsFID.Form.Objects[$($Script:refs['TreeView'].Nodes | Where-Object { $_.Text -match "^Form - " }).Name].width = $Script:refsFID.Form.Objects[$($Script:refs['TreeView'].Nodes | Where-Object { $_.Text -match "^Form - " }).Name].width * $tscale
            $Script:refsFID.Form.Objects[$($Script:refs['TreeView'].Nodes | Where-Object { $_.Text -match "^Form - " }).Name].tag = "VisualStyle,DPIAware"
						
						
            Remove-Variable -Name eventSB, reuseContextInfo
        }
        catch {
            Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered before ShowDialog."
            $noIssues = $false
        }

        # Load icon from Base64String
        
                # Converts image to Base64String
                $encodedImage = [convert]::ToBase64String((get-content $inputfile -encoding byte))
                $encodedImage -replace ".{80}", "$&`r`n" | set-content $outputfile
            
                try {
            $Script:refs['MainForm'].Icon = [System.Drawing.Icon]::FromHandle(
                ([System.Drawing.Bitmap][System.Drawing.Image]::FromStream(
                    [System.IO.MemoryStream][System.Convert]::FromBase64String(@"
iVBORw0KGgoAAAANSUhEUgAAAJYAAACWCAYAAAA8AXHiAAAACXBIWXMAAC4jAAAuIwF4pT92AAAKZUlE
QVR4nO3dfWxV5R3A8e+9a237MPBSLoWmuljQIEi9VKvp4tAYi3TTsBJAg44ZYv9Bcd2mqTK3NoGqibou
WtFEomEjpibTzvmSrGEQHCEdy4SLa1kTeRFEBVnKJdWnTV9u90cpAkLvc+85zz33nv4+SRNjz3nOz/Tr
6bnnvhSEEEIIIYQQQgghhBBCCCFEhgvYWlhrvQFYY2t9HxsE/gPsOvO1WynV6+1IycuxuPYkYJrF9f1s
JrDozD/Htdb7+Da0D7IhtKDXA4iEgkA5sBZoBY5prZu11qXejjU+CSv7TAF+BRzQWrdprW/TWlu7pEmV
hJW9gsBSYAewR2u91Ntxzidh+cMCoE1r/abWOuz1MCBh+c29QJfWusbrQSQs/ykC/qK13qK1nurVEDZv
NyS0d+9ehoaGHK1RWlpKOOzs7H/8+HE+++wzR2u4paSkhOLiYgIBx9fjPwPu0FovVUrtdmG0pHga1rPP
Pktvr7NbMvfffz8rV650tMY777zD+++/72gNN4VCIebOnct1113H3LlzmT17Njk5Kf2oioG/a61/opTa
6fKY4/I0LDccOHAgI9ZwUywWo6Ojg46ODgAKCwu56667qK6u5vLLL092ue8Df9NaL1FKbXN71kvJ+mus
Tz75xNH+w8PDHDp0yKVp7Ojp6WHLli2sXr2alpYWjhw5kuwSCvhAa/1jC+NdVNaH1dPTw+7dqV9CbNu2
jYGBARcnsmdgYID29nYefvhhnnvuuWQvI/KAv2qtf2ppvPNkfVgALS0tKV2rffXVV2zatMnCRPZ9+OGH
rFmzJtn/qXKBt7TWP7I01lm+CCsWi/Hyyy8zMjJivM/Q0BAvvPACfX19FiezKxaLsWHDBpqbm/n6669N
d8sB3rB9K8IXYQHs3LmTJ554gi+//DLhtkeOHOHRRx9l3759aZjMvu3bt1NXV8fx48dNd/kBsMnmc4y+
CQugq6uLRx55hLa2No4ePUo8Hj/7veHhYT799FNaW1upq6vj4MGDHk7qvhMnTvD4449z7Ngx012WAbW2
5rH5Qr9mRp+Fv6SVK1c6vo81nvz8fGbNmkU8HufQoUNZc5HuRCgUoqmpiauuuspk8z6gQim13+05fHXG
ulB/fz/79++nu7t7QkQFo9dd69atMz0jFwBvaq3z3J7D12FNVL29vTQ1NZle0JcBP3d7BgnLp06ePElL
S4vpI+V1WmtXn4WRsHxs165dtLe3m2xaCtzn5rElLJ979dVXOXr0qMmmv9Faf8+t40pYPjcwMMCLL75o
8itxDrDcreNKWBNAd3c3H3/8scmmv9Vau9KEhJXhXHjBHwCtra0mm80HbnDjeFn/eiy/KC4upry8nLKy
MqZPn04oFCIUCpGXl4fWmtOnTxOLxfjiiy+IRqNEo1FisZjx+p2dnXR2djJ//vxEm1YD/3by3wI+v/Oe
6aZOncqSJUu49dZbmTFjRlL7joyMcPjwYdrb29m6davRDeAFCxbQ1NSUaLNdSinHr36QsDxQUlLCsmXL
uP3228nNzXW8XiwW47333uPdd99N+GqN119/naKiovE2iQNhpdQpJzPJNVYaBQIBVqxYwUsvvcSdd97p
SlQw+vzgqlWr2LhxI2VlZeNuu2fPnkTLBYE7nM4kYaVJSUkJzz//PA888IBrQV2oqKiIp59+mtra2ku+
+eKjjz4yWara6SwSVhpce+21NDc3M2fOHOvHCgQC1NTU0NjYyGWXXfad70ejUZO33C12OoeEZVkkEqGp
qYlJkyal9bjl5eU0NjaSl3f+Cxf6+vro7u5OtPsVWusCJ8eXsCwqKyujsbGR/Px8T44fiURoaGggGDz/
x9zZ2Wmye3IPUy/g67DC4TCVlZXcdNNNhEKhtB47FApRX19/0V9Hhk4y+kkybwD/AnQqi0QiEe677/zn
l0+dMnrA5ygs390gnTx5Mg8++CA33ngjU6d++36BkZERenp66OjoYPPmzfT391ubIRAIUF9ff97xDcSB
PwF/BLqUUifP/eaZp1pKgQjwS2Ch6cL33HMP0Wj07Jmqp6fHZLeZputfjK/OWJWVlbzyyitUVVV954ca
CASYNm0ad999Nxs3buT666+3NsfSpUuTXf9tYL5SarVSaseFUQEopeJKqYNKqTbgNkafMD5ssngwGOSx
xx47e/ZMxxnLN2EtXryYJ5980uhX3owZM3jqqaeorKx0fY6CggJWrFhhuvn/gB8qpZYrpf5rupNSakQp
9TYwD9hgsk84HKa6evQugmFYcsYqKiqitrY2qSdsA4EAa9euZfLkya7OUlNTY7rmKaBKKfXPVI+llOpX
SjUAvzfZfvny5eTm5soZy1RdXR0FBck/Og6FQjz00EOuzZGfn09NjdFnnp0GFiml3HpjYz3wVqKNCgsL
qaqqMn1A4ejzpbI+rOnTpxOJRFLe/5ZbbnHtdkBFRYXp/aplSimjW+AmlFJxYBWQ8Oy3cOFCCgsLTZY1
fvfrxWR9WNdcc42j/YPBILNmzXJllptvvtlks3/Y+DghpVQ/8LtE282bN48rr7zSZMmJHdbVV1/teA2n
ccLoNVtFRYXJps84PtilbSfBI8WcnBwWLVo03iZjHIXl6X2s9evXMzw87GiN4uJix3O4scbMmTOZMmVK
os2igNHbZlKhlIprrV8Dxn3R1Q03GL1INHvDcuNM4YYLn/KwuEabUsr8I3FSsxn4BaNvn/+G0Tv235z7
FQwGv7nw313ky/j2x8X47s57hnN2ejaglPoch7cK3JD111giM0lYwgoJS1ghYQkrJCxhhc1HhScBZx/C
7o4gMNvrISYaa2EppZ7B7l1mI1prxeh9GZFG8qtQWCFhCSskLGGFhCWskLCEFRKWsELCElZIWMIKCUtY
IWEJKyQsYYWEJayYCGFd4fUA58ikWazydVha61Jgq9dznGON1nrcT5L2C9+GdSaqHYz+/eNM0jwR4vJl
WBkc1Rjfx+W7sJKNqr+/nx07djg+7okTJ9i7d28yu/g6Ll+FlUpUjY2N7N/v/G9tDw0NsX79eonrDGt/
8iTdUo2qq6vL1Tlyc3NpaGigvLw8md1+rZT6g6uDeMwXYWVKVGMkLh+ElWlRjZnocfkhrDeBe022TVdU
Y1KMq1gp5egjhDKBHy7ejf5AdrqjAhgcHEzlgt61P/jtJT+ElZAXUY1JMa6s5/uw4vG4Z1GNGYvLyxnS
zfdhDQ4OZsQPNFPmSBffhyW8IWEJKyQsYYWEJayQsIQVEpawQsISVkhYwgoJS1ghYQkrJCxhhYQlrJCw
hBUSlrBCwhJWSFjCCglLWCFhCSskLGGFhCWskLCEFRKWsELCElZIWMIKCUtYIWEJKyQsYYWEJayQsIQV
EpawQsISVkhYwgoJS1ghYQkrJCxhhYQlrJCwhBUSlrBCwhJWSFjCCglLWJHj9QC2BQIBwuGw12MAoJTy
eoS08cOflfszsNzrOVx0hVLqc6+HcEp+FQorJCxhhYQlrJCwhBUSlrBCwhJWSFjCCj/cIH0b6PZ6CBf1
ej2AEEIIIYQQQgghhBBCCAf+D8bAORTSU3R+AAAAAElFTkSuQmCC
"@                  )
                )).GetHicon()
            )
        } catch {
            Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered loading Form icon."
            $noIssues = $false
        }

        # Declare Strings Used During Script File Generation
        $Script:templateText = @{
            Notes                               = ([string[]]`
                    "<#",
                "    .NOTES",
                "    ===========================================================================",
                "        FileName:  FNAME",
                "        Author:  NETNAME",
                "        Created On:  DATE",
                "        Last Updated:  DATE",
                "        Organization:",
                "        Version:      v0.1",
                "    ===========================================================================",
                "",
                "    .DESCRIPTION",
                "",
                "    .DEPENDENCIES",
                "#>",
                ""
            )
            Start_STAScriptBlock                = ([string[]]`
                    "# ScriptBlock to Execute in STA Runspace",
                "`$sbGUI = {",
                "    param(`$BaseDir)",
                "Add-Type `@`"",
                "using System;",
                "using System.Collections.Generic;",
                "using System.Windows.Forms;",
                "using System.Runtime.InteropServices;",
                "public class psd {",
                "public static void SetCompat()",
                "{",
                "//	SetProcessDPIAware();",
                "Application.EnableVisualStyles();",
                "Application.SetCompatibleTextRenderingDefault(false);",
                "}",
                "[System.Runtime.InteropServices.DllImport(`"user32.dll`")]",
                "public static extern bool SetProcessDPIAware();",
                "}",
                "`"`@  -ReferencedAssemblies System.Windows.Forms,System.Drawing,System.Drawing.Primitives,System.Net.Primitives,System.ComponentModel.Primitives,Microsoft.Win32.Primitives",
                "`$script:tscale = 1",
                ""
            )
            StartRegion_Functions               = ([string[]]`
                    "    #region Functions",
                ""
            )
            Function_Update_ErrorLog            = ([string[]]`
                    "    function Update-ErrorLog {",
                "        param(",
                "            [System.Management.Automation.ErrorRecord]`$ErrorRecord,",
                "            [string]`$Message,",
                "            [switch]`$Promote",
                "        )",
                "",
                "        if ( `$Message -ne '' ) {[void][System.Windows.Forms.MessageBox]::Show(`"`$(`$Message)``r``n``r``nCheck '`$(`$BaseDir)\exceptions.txt' for details.`",'Exception Occurred')}",
                "",
                "        `$date = Get-Date -Format 'yyyyMMdd HH:mm:ss'",
                "        `$ErrorRecord | Out-File `"`$(`$BaseDir)\tmpError.txt`"",
                "",
                "        Add-Content -Path `"`$(`$BaseDir)\exceptions.txt`" -Value `"`$(`$date): `$(`$(Get-Content `"`$(`$BaseDir)\tmpError.txt`") -replace `"\s+`",`" `")`"",
                "",
                "        Remove-Item -Path `"`$(`$BaseDir)\tmpError.txt`"",
                "",
                "        if ( `$Promote ) {throw `$ErrorRecord}",
                "    }",
                ""
            )
            Function_ConvertFrom_WinFormsXML    = ([string[]]`
                    "    function ConvertFrom-WinFormsXML {",
                "        param(",
                "            [Parameter(Mandatory=`$true)]`$Xml,",
                "            [string]`$Reference,",
                "            `$ParentControl,",
                "            [switch]`$Suppress",
                "        )",
                "",
                "        try {",
                "            if ( `$Xml.GetType().Name -eq 'String' ) {`$Xml = ([xml]`$Xml).ChildNodes}",
                "",
                "            if ( `$Xml.ToString() -ne 'SplitterPanel' ) {`$newControl = New-Object System.Windows.Forms.`$(`$Xml.ToString())}",
                "",
                "            if ( `$ParentControl ) {",
                "#brandoncomputer_ToolStripFix_Export",
                "				if ( `$Xml.ToString() -eq 'ToolStrip' ) {",
                "					`$newControl = New-Object System.Windows.Forms.MenuStrip",
                "					`$ParentControl.Controls.Add(`$newControl)",
                "				}",
                "				else {",
                "                if ( `$Xml.ToString() -match `"^ToolStrip`" ) {",
                "                    if ( `$ParentControl.GetType().Name -match `"^ToolStrip`" ) {[void]`$ParentControl.DropDownItems.Add(`$newControl)} else {[void]`$ParentControl.Items.Add(`$newControl)}",
                "                } elseif ( `$Xml.ToString() -eq 'ContextMenuStrip' ) {`$ParentControl.ContextMenuStrip = `$newControl}",
                "                elseif ( `$Xml.ToString() -eq 'SplitterPanel' ) {`$newControl = `$ParentControl.`$(`$Xml.Name.Split('_')[-1])}",
                "                else {`$ParentControl.Controls.Add(`$newControl)}",
                "				}",
                "            }",
                "",
                "            `$Xml.Attributes | ForEach-Object {",
                "                `$attrib = `$_",
                "                `$attribName = `$_.ToString()",
                "				`$attrib = `$_",
                "				`$attribName = `$_.ToString()",
                "								",
                "				if (`$attribName -eq 'Size'){",
                "					",
                "					`$n = `$attrib.Value.split(',')",
                "					`$n[0] = [math]::round((`$n[0]/1) * `$tscale)",
                "					`$n[1] = [math]::round((`$n[1]/1) * `$tscale)",
                "				if (`"`$(`$n[0]),`$(`$n[1])`" -ne `",`") {",
                "					`$attrib.Value = `"`$(`$n[0]),`$(`$n[1])`"",
                "				}",
                "				}",
                "				if (`$attribName -eq 'Location'){",
                "					`$n = `$attrib.Value.split(',')",
                "					`$n[0] = [math]::round((`$n[0]/1) * `$tscale)",
                "					`$n[1] = [math]::round((`$n[1]/1) * `$tscale)",
                "				if (`"`$(`$n[0]),`$(`$n[1])`" -ne `",`") {",
                "					`$attrib.Value = `"`$(`$n[0]),`$(`$n[1])`"",
                "				}",
                "				}",
                "				if (`$attribName -eq 'MaximumSize'){",
                "					`$n = `$attrib.Value.split(',')",
                "					`$n[0] = [math]::round((`$n[0]/1) * `$tscale)",
                "					`$n[1] = [math]::round((`$n[1]/1) * `$tscale)",
                "				if (`"`$(`$n[0]),`$(`$n[1])`" -ne `",`") {",
                "					`$attrib.Value = `"`$(`$n[0]),`$(`$n[1])`"",
                "				}",
                "				}",
                "				if (`$attribName -eq 'MinimumSize'){",
                "					`$n = `$attrib.Value.split(',')",
                "					`$n[0] = [math]::round((`$n[0]/1) * `$tscale)",
                "					`$n[1] = [math]::round((`$n[1]/1) * `$tscale)",
                "				if (`"`$(`$n[0]),`$(`$n[1])`" -ne `",`") {",
                "					`$attrib.Value = `"`$(`$n[0]),`$(`$n[1])`"",
                "				}",
                "				}",
                "				if (`$attribName -eq 'ImageScalingSize'){",
                "					`$n = `$attrib.Value.split(',')",
                "					`$n[0] = [math]::round((`$n[0]/1) * `$tscale)",
                "					`$n[1] = [math]::round((`$n[1]/1) * `$tscale)",
                "				if (`"`$(`$n[0]),`$(`$n[1])`" -ne `",`") {",
                "					`$attrib.Value = `"`$(`$n[0]),`$(`$n[1])`"",
                "				}",
                "				}",
                "",
                "                if ( `$Script:specialProps.Array -contains `$attribName ) {",
                "                    if ( `$attribName -eq 'Items' ) {",
                "                        `$(`$_.Value -replace `"\|\*BreakPT\*\|`",`"``n`").Split(`"``n`") | ForEach-Object{[void]`$newControl.Items.Add(`$_)}",
                "                    } else {",
                "                            # Other than Items only BoldedDate properties on MonthCalendar control",
                "                        `$methodName = `"Add`$(`$attribName)`" -replace `"s$`"",
                "",
                "                        `$(`$_.Value -replace `"\|\*BreakPT\*\|`",`"``n`").Split(`"``n`") | ForEach-Object{`$newControl.`$attribName.`$methodName(`$_)}",
                "                    }",
                "                } else {",
                "                    switch (`$attribName) {",
                "                        FlatAppearance {",
                "                            `$attrib.Value.Split('|') | ForEach-Object {`$newControl.FlatAppearance.`$(`$_.Split('=')[0]) = `$_.Split('=')[1]}",
                "                        }",
                "                        default {",
                "                            if ( `$null -ne `$newControl.`$attribName ) {",
                "                                if ( `$newControl.`$attribName.GetType().Name -eq 'Boolean' ) {",
                "                                    if ( `$attrib.Value -eq 'True' ) {`$value = `$true} else {`$value = `$false}",
                "                                } else {`$value = `$attrib.Value}",
                "                            } else {`$value = `$attrib.Value}",
                "#brandoncomputer_VariousDialogFixesInExport",
                "							switch (`$xml.ToString()) {",
                "								`"FolderBrowserDialog`" {",
                "									if (`$xml.Description)",
                "										{`$newControl.Description = `$xml.Description}",
                "									if (`$xml.Tag)",
                "										{`$newControl.Tag = `$xml.Tag}",
                "									if (`$xml.RootFolder)",
                "										{`$newControl.RootFolder = `$xml.RootFolder}",
                "									if (`$xml.SelectedPath)",
                "										{`$newControl.SelectedPath = `$xml.SelectedPath}",
                "									if (`$xml.ShowNewFolderButton)",
                "										{`$newControl.ShowNewFolderButton = `$xml.ShowNewFolderButton}",
                "								}",
                "								`"OpenFileDialog`" {",
                "									if (`$xml.AddExtension)",
                "										{`$newControl.AddExtension = `$xml.AddExtension}",
                "									if (`$xml.AutoUpgradeEnabled)",
                "										{`$newControl.AutoUpgradeEnabled = `$xml.AutoUpgradeEnabled}",
                "									if (`$xml.CheckFileExists)",
                "										{`$newControl.CheckFileExists = `$xml.CheckFileExists}",
                "									if (`$xml.CheckPathExists)",
                "										{`$newControl.CheckPathExists = `$xml.CheckPathExists}",
                "									if (`$xml.DefaultExt)",
                "										{`$newControl.DefaultExt = `$xml.DefaultExt}",
                "									if (`$xml.DereferenceLinks)",
                "										{`$newControl.DereferenceLinks = `$xml.DereferenceLinks}",
                "									if (`$xml.FileName)",
                "										{`$newControl.FileName = `$xml.FileName}",
                "									if (`$xml.Filter)",
                "										{`$newControl.Filter = `$xml.Filter}",
                "									if (`$xml.FilterIndex)",
                "										{`$newControl.FilterIndex = `$xml.FilterIndex}",
                "									if (`$xml.InitialDirectory)",
                "										{`$newControl.InitialDirectory = `$xml.InitialDirectory}",
                "									if (`$xml.Multiselect)",
                "										{`$newControl.Multiselect = `$xml.Multiselect}",
                "									if (`$xml.ReadOnlyChecked)",
                "										{`$newControl.ReadOnlyChecked = `$xml.ReadOnlyChecked}",
                "									if (`$xml.RestoreDirectory)",
                "										{`$newControl.RestoreDirectory = `$xml.RestoreDirectory}",
                "									if (`$xml.ShowHelp)",
                "										{`$newControl.ShowHelp = `$xml.ShowHelp}",
                "									if (`$xml.ShowReadOnly)",
                "										{`$newControl.ShowReadOnly = `$xml.ShowReadOnly}",
                "									if (`$xml.SupportMultiDottedExtensions)",
                "										{`$newControl.SupportMultiDottedExtensions = `$xml.SupportMultiDottedExtensions}",
                "									if (`$xml.Tag)",
                "										{`$newControl.Tag = `$xml.Tag}",
                "									if (`$xml.Title)",
                "										{`$newControl.Title = `$xml.Title}",
                "									if (`$xml.ValidateNames)",
                "										{`$newControl.ValidateNames = `$xml.ValidateNames}",
                "								}",
                "								`"ColorDialog`" {",
                "									if (`$xml.AllowFullOpen)",
                "										{`$newControl.AllowFullOpen = `$xml.AllowFullOpen}",
                "									if (`$xml.AnyColor)",
                "										{`$newControl.AnyColor = `$xml.AnyColor}",
                "									if (`$xml.Color)",
                "										{`$newControl.Color = `$xml.Color}",
                "									if (`$xml.FullOpen)",
                "										{`$newControl.FullOpen = `$xml.FullOpen}",
                "									if (`$xml.ShowHelp)",
                "										{`$newControl.ShowHelp = `$xml.ShowHelp}",
                "									if (`$xml.SolidColorOnly)",
                "										{`$newControl.SolidColorOnly = `$xml.SolidColorOnly}",
                "									if (`$xml.Tag)",
                "										{`$newControl.Tag = `$xml.Tag}									",
                "								}",
                "								`"FontDialog`" {",
                "									if (`$xml.AllowScriptChange)",
                "										{`$newControl.AllowScriptChange = `$xml.AllowScriptChange}",
                "									if (`$xml.AllowSimulations)",
                "										{`$newControl.AllowSimulations = `$xml.AllowSimulations}",
                "									if (`$xml.AllowVectorFonts)",
                "										{`$newControl.AllowVectorFonts = `$xml.AllowVectorFonts}",
                "									if (`$xml.Color)",
                "										{`$newControl.Color = `$xml.Color}",
                "									if (`$xml.FixedPitchOnly)",
                "										{`$newControl.FixedPitchOnly = `$xml.FixedPitchOnly}",
                "									if (`$xml.Font)",
                "										{`$newControl.Font = `$xml.Font}",
                "									if (`$xml.FontMustExists)",
                "										{`$newControl.FontMustExists = `$xml.FontMustExists}		",
                "									if (`$xml.MaxSize)",
                "										{`$newControl.MaxSize = `$xml.MaxSize}",
                "									if (`$xml.MinSize)",
                "										{`$newControl.MinSize = `$xml.MinSize}",
                "									if (`$xml.ScriptsOnly)",
                "										{`$newControl.ScriptsOnly = `$xml.ScriptsOnly}",
                "									if (`$xml.ShowApply)",
                "										{`$newControl.ShowApply = `$xml.ShowApply}",
                "									if (`$xml.ShowColor)",
                "										{`$newControl.ShowColor = `$xml.ShowColor}",
                "									if (`$xml.ShowEffects)",
                "										{`$newControl.ShowEffects = `$xml.ShowEffects}",
                "									if (`$xml.ShowHelp)",
                "										{`$newControl.ShowHelp = `$xml.ShowHelp}",
                "									if (`$xml.Tag)",
                "										{`$newControl.Tag = `$xml.Tag}											",
                "								}",
                "								`"PageSetupDialog`" {",
                "									if (`$xml.AllowMargins)",
                "										{`$newControl.AllowMargins = `$xml.AllowMargins}",
                "									if (`$xml.AllowOrientation)",
                "										{`$newControl.AllowOrientation = `$xml.AllowOrientation}",
                "									if (`$xml.AllowPaper)",
                "										{`$newControl.AllowPaper = `$xml.AllowPaper}",
                "									if (`$xml.Document)",
                "										{`$newControl.Document = `$xml.Document}",
                "									if (`$xml.EnableMetric)",
                "										{`$newControl.EnableMetric = `$xml.EnableMetric}",
                "									if (`$xml.MinMargins)",
                "										{`$newControl.MinMargins = `$xml.MinMargins}",
                "									if (`$xml.ShowHelp)",
                "										{`$newControl.ShowHelp = `$xml.ShowHelp}		",
                "									if (`$xml.ShowNetwork)",
                "										{`$newControl.ShowNetwork = `$xml.ShowNetwork}",
                "									if (`$xml.Tag)",
                "										{`$newControl.Tag = `$xml.Tag}								",
                "								}",
                "								`"PrintDialog`" {",
                "									if (`$xml.AllowCurrentPage)",
                "										{`$newControl.AllowCurrentPage = `$xml.AllowCurrentPage}",
                "									if (`$xml.AllowPrintToFile)",
                "										{`$newControl.AllowPrintToFile = `$xml.AllowPrintToFile}",
                "									if (`$xml.AllowSelection)",
                "										{`$newControl.AllowSelection = `$xml.AllowSelection}",
                "									if (`$xml.AllowSomePages)",
                "										{`$newControl.AllowSomePages = `$xml.AllowSomePages}",
                "									if (`$xml.Document)",
                "										{`$newControl.Document = `$xml.Document}",
                "									if (`$xml.PrintToFile)",
                "										{`$newControl.PrintToFile = `$xml.PrintToFile}",
                "									if (`$xml.ShowHelp)",
                "										{`$newControl.ShowHelp = `$xml.ShowHelp}		",
                "									if (`$xml.ShowNetwork)",
                "										{`$newControl.ShowNetwork = `$xml.ShowNetwork}",
                "									if (`$xml.Tag)",
                "										{`$newControl.Tag = `$xml.Tag}",
                "									if (`$xml.UseEXDialog)",
                "										{`$newControl.UseEXDialog = `$xml.UseEXDialog}",
                "								}",
                "								`"PrintPreviewDialog`" {",
                "									if (`$xml.AutoSizeMode)",
                "										{`$newControl.AutoSizeMode = `$xml.AutoSizeMode}",
                "									if (`$xml.Document)",
                "										{`$newControl.Document = `$xml.Document}",
                "									if (`$xml.MainMenuStrip)",
                "										{`$newControl.MainMenuStrip = `$xml.MainMenuStrip}",
                "									if (`$xml.ShowIcon)",
                "										{`$newControl.ShowIcon = `$xml.ShowIcon}",
                "									if (`$xml.UseAntiAlias)",
                "										{`$newControl.UseAntiAlias = `$xml.UseAntiAlias}",
                "								}",
                "								`"SaveFileDialog`" {",
                "									if (`$xml.AddExtension)",
                "										{`$newControl.AddExtension = `$xml.AddExtension}",
                "									if (`$xml.AutoUpgradeEnabled)",
                "										{`$newControl.AutoUpgradeEnabled = `$xml.AutoUpgradeEnabled}",
                "									if (`$xml.CheckFileExists)",
                "										{`$newControl.CheckFileExists = `$xml.CheckFileExists}",
                "									if (`$xml.CheckPathExists)",
                "										{`$newControl.CheckPathExists = `$xml.CheckPathExists}",
                "									if (`$xml.CreatePrompt)",
                "										{`$newControl.CreatePrompt = `$xml.CreatePrompt}",
                "									if (`$xml.DefaultExt)",
                "										{`$newControl.DefaultExt = `$xml.DefaultExt}",
                "									if (`$xml.DereferenceLinks)",
                "										{`$newControl.DereferenceLinks = `$xml.DereferenceLinks}",
                "									if (`$xml.FileName)",
                "										{`$newControl.FileName = `$xml.FileName}",
                "									if (`$xml.Filter)",
                "										{`$newControl.Filter = `$xml.Filter}",
                "									if (`$xml.FilterIndex)",
                "										{`$newControl.FilterIndex = `$xml.FilterIndex}",
                "									if (`$xml.InitialDirectory)",
                "										{`$newControl.InitialDirectory = `$xml.InitialDirectory}",
                "									if (`$xml.Multiselect)",
                "										{`$newControl.OverwritePrompt = `$xml.OverwritePrompt}",
                "									if (`$xml.RestoreDirectory)",
                "										{`$newControl.RestoreDirectory = `$xml.RestoreDirectory}",
                "									if (`$xml.ShowHelp)",
                "										{`$newControl.ShowHelp = `$xml.ShowHelp}",
                "									if (`$xml.SupportMultiDottedExtensions)",
                "										{`$newControl.SupportMultiDottedExtensions = `$xml.SupportMultiDottedExtensions}",
                "									if (`$xml.Tag)",
                "										{`$newControl.Tag = `$xml.Tag}",
                "									if (`$xml.Title)",
                "										{`$newControl.Title = `$xml.Title}",
                "									if (`$xml.ValidateNames)",
                "										{`$newControl.ValidateNames = `$xml.ValidateNames}",
                "								}",
                "								`"Timer`" {",
                "									if (`$xml.Enabled)",
                "										{`$newControl.Enabled = `$xml.Enabled}",
                "									if (`$xml.Interval)",
                "										{`$newControl.Interval = `$xml.Interval}",
                "									if (`$xml.Tag)",
                "										{`$newControl.Tag = `$xml.Tag}",						
                "								}",
                "								default {",
                "									`$newControl.`$attribName = `$value",
                "								}",
                "							}",
                "						}",
                "					}",
                "				}",
                "",
                "",
                "",
                "#brandoncomputer_DirectReferenceObjectsExport",
                "           	if (`$newControl.Name){",
                "             		New-Variable -Name `$newControl.Name -Scope Script -Value `$newControl | Out-Null",
                "             	}",
                "                if (( `$attrib.ToString() -eq 'Name' ) -and ( `$Reference -ne '' )) {",
                "                    try {`$refHashTable = Get-Variable -Name `$Reference -Scope Script -ErrorAction Stop}",
                "                    catch {",
                "                        New-Variable -Name `$Reference -Scope Script -Value @{} | Out-Null",
                "                        `$refHashTable = Get-Variable -Name `$Reference -Scope Script -ErrorAction SilentlyContinue",
                "                    }",
                "",
                "                    `$refHashTable.Value.Add(`$attrib.Value,`$newControl)",
                "                }",
                "            }",
                "",
                "            if ( `$Xml.ChildNodes ) {`$Xml.ChildNodes | ForEach-Object {ConvertFrom-WinformsXML -Xml `$_ -ParentControl `$newControl -Reference `$Reference -Suppress}}",
                "",
                "            if ( `$Suppress -eq `$false ) {return `$newControl}",
                "        } catch {Update-ErrorLog -ErrorRecord `$_ -Message `"Exception encountered adding `$(`$Xml.ToString()) to `$(`$ParentControl.Name)`"}",
                "    }",
                ""
            )
            Function_Get_CustomControl          = ([string[]]`
                    "    function Get-CustomControl {",
                "        param(",
                "            [Parameter(Mandatory=`$true)][hashtable]`$ControlInfo,",
                "            [string]`$Reference,",
                "            [switch]`$Suppress",
                "        )",
                "",
                "        try {",
                "            `$refGuid = [guid]::NewGuid()",
                "            `$control = ConvertFrom-WinFormsXML -Xml `"`$(`$ControlInfo.XMLText)`" -Reference `$refGuid",
                "            `$refControl = Get-Variable -Name `$refGuid -ValueOnly",
                "",
                "            if ( `$ControlInfo.Events ) {`$ControlInfo.Events.ForEach({`$refControl[`$_.Name].`"add_`$(`$_.EventType)`"(`$_.ScriptBlock)})}",
                "",
                "            if ( `$Reference -ne '' ) {New-Variable -Name `$Reference -Scope Script -Value `$refControl}",
                "",
                "            Remove-Variable -Name refGuid -Scope Script",
                "",
                "            if ( `$Suppress -eq `$false ) {return `$control}",
                "        } catch {Update-ErrorLog -ErrorRecord `$_ -Message `"Exception encountered getting special control.`"}",
                "    }",
                ""
            )
            EndRegion_Functions                 = ([string[]]`
                    "    #endregion Functions",
                ""
            )

            StartRegion_ChildForms              = ([string[]]`
                    "    #region Child Forms",
                "",
                "    `$Script:childFormInfo = @{"
            )
            EndRegion_ChildForms                = ([string[]]`
                    "    }",
                "",
                "    #endregion Child Forms",
                ""
            )
            StartRegion_Timers                  = ([string[]]`
                    "    #region Timers",
                "",
                "    `$Script:timerInfo = @{",
                ""
            )
            EndRegion_Timers                    = ([string[]]`
                    "    }",
                "",
                "    #endregion Timers",
                ""
            )
            StartRegion_Dialogs                 = ([string[]]`
                    "    #region Dialogs",
                "",
                "    `$Script:dialogInfo = @{"
            )
            EndRegion_Dialogs                   = ([string[]]`
                    "    }",
                "",
                "    #endregion Dialogs",
                ""
            )
            StartRegion_ContextMenuStrips       = ([string[]]`
                    "    #region Reusable ContextMenuStrips",
                "",
                "    `$Script:reuseContextInfo = @{"
            )
            EndRegion_ContextMenuStrips         = ([string[]]`
                    "    }",
                "",
                "    #endregion Reusable ContextMenuStrips",
                ""
            )
            Region_EnvSetup                     = ([string[]]`
                    "    #region Environment Setup",
                "",
                "    try {",
                "        Add-Type -AssemblyName System.Windows.Forms",
                "        Add-Type -AssemblyName System.Drawing",
                "",
                "",
                "    } catch {Update-ErrorLog -ErrorRecord `$_ -Message `"Exception encountered during Environment Setup.`"}",
                "",
                "    #endregion Environment Setup",
                ""
            )
            StartRegion_Events                  = ([string[]]`
                    "    #region Event ScriptBlocks",
                ""
                #brandoncomputer_RemoveAbstractionFromRegion
                # "    `$eventSB = @{"
            )
            #     "    }",
            #    "", VV
            EndRegion_Events                    = ([string[]]`
                    "    #endregion Event ScriptBlocks",
                ""
            )
            StartRegion_EventAssignment         = ([string[]]`
                    "    #region Event Assignment",
                "",
                "    try {"
            )
            EndRegion_EventAssignment           = ([string[]]`
                    "    } catch {Update-ErrorLog -ErrorRecord `$_ -Message `"Exception encountered during Event Assignment.`"}",
                "",
                "    #endregion Event Assignment",
                ""
            )
            Region_OtherActions                 = ([string[]]`
                    "    #region Other Actions Before ShowDialog",
                "",
                "    try {",
                "        Remove-Variable -Name eventSB",
                "    } catch {Update-ErrorLog -ErrorRecord `$_ -Message `"Exception encountered before ShowDialog.`"}",
                "",
                "    #endregion Other Actions Before ShowDialog",
                "",
                "        # Show the form"
            )
            Region_AfterClose_EndSTAScriptBlock = ([string[]]`
                    "    <#",
                "    #region Actions After Form Closed",
                "",
                "    try {",
                "",
                "    } catch {Update-ErrorLog -ErrorRecord `$_ -Message `"Exception encountered after Form close.`"}",
                "",
                "    #endregion Actions After Form Closed",
                "    #>",
                "}",
                ""
            )
            Region_StartPoint                   = ([string[]]`
                    "#region Start Point of Execution",
                "",
                "    # Initialize STA Runspace",
                "`$rsGUI = [Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()",
                "`$rsGUI.ApartmentState = 'STA'",
                "`$rsGUI.ThreadOptions = 'ReuseThread'",
                "`$rsGUI.Open()",
                "",
                "    # Create the PSCommand, Load into Runspace, and BeginInvoke",
                "`$cmdGUI = [Management.Automation.PowerShell]::Create().AddScript(`$sbGUI).AddParameter('BaseDir',`$PSScriptRoot)",
                "`$cmdGUI.RunSpace = `$rsGUI",
                "`$handleGUI = `$cmdGUI.BeginInvoke()",
                "",
                "    # Hide Console Window",
                "Add-Type -Name Window -Namespace Console -MemberDefinition '",
                "[DllImport(`"Kernel32.dll`")]",
                "public static extern IntPtr GetConsoleWindow();",
                "",
                "[DllImport(`"user32.dll`")]",
                "public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);",
                "'",
                "",
                "[Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 0)",
                "",
                "    #Loop Until GUI Closure",
                "while ( `$handleGUI.IsCompleted -eq `$false ) {Start-Sleep -Seconds 5}",
                "",
                "    # Dispose of GUI Runspace/Command",
                "`$cmdGUI.EndInvoke(`$handleGUI)",
                "`$cmdGUI.Dispose()",
                "`$rsGUI.Dispose()",
                "",
                "Exit",
                "",
                "#endregion Start Point of Execution"
            )
        }
    }

    #endregion Other Actions Before ShowDialog

    # Show the form
    try {
        #brandoncomputer_FastTextEditWindowCreate
        $eventForm = New-Object System.Windows.Forms.Form
        $eventForm.Text = "Events"

        try {
            if ((Get-Module -ListAvailable powershell-designer).count -gt 1) {
                [Reflection.Assembly]::LoadFile("$(split-path -path (Get-Module -ListAvailable powershell-designer)[0].path)\FastColoredTextBox.dll") | out-null
            }
            else {
                [Reflection.Assembly]::LoadFile("$(split-path -path (Get-Module -ListAvailable powershell-designer).path)\FastColoredTextBox.dll") | out-null
            }
        }
        catch {
            [Reflection.Assembly]::LoadFile("$BaseDir\FastColoredTextBox.dll") | out-null
        }

        $FastText = New-Object FastColoredTextBoxNS.FastColoredTextBox
        $FastText.Language = "DialogShell"
        $FastText.Dock = "Fill"
        $FastText.Zoom = 100
        $eventForm.Controls.Add($FastText)
        $eventForm.MDIParent = $refs['MainForm']
        $eventForm.Dock = "Bottom"
        $eventForm.ControlBox = $false
        $eventForm.ShowIcon = $false

        $xpopup = New-Object System.Windows.Forms.ContextMenuStrip
        $undo = new-object System.Windows.Forms.ToolStripMenuItem
        $undo.text = "Undo"
        $undo.Add_Click({ $FastText.Undo() })
        $xpopup.Items.Add($undo)

        $redo = new-object System.Windows.Forms.ToolStripMenuItem
        $redo.text = "Redo"
        $redo.Add_Click({ $FastText.Redo() })
        $xpopup.Items.Add($redo)

        $xpSep1 = new-object System.Windows.Forms.ToolStripSeparator
        $xpopup.Items.Add($xpSep1)

        $Cut = new-object System.Windows.Forms.ToolStripMenuItem
        $Cut.text = "Cut"
        $Cut.Add_Click({ $FastText.Cut()
            })
        $xpopup.Items.Add($Cut)

        $Copy = new-object System.Windows.Forms.ToolStripMenuItem
        $Copy.text = "Copy"
        $Copy.Add_Click({ $FastText.Copy() })
        $xpopup.Items.Add($Copy)

        $Paste = new-object System.Windows.Forms.ToolStripMenuItem
        $Paste.text = "Paste"
        $Paste.Add_Click({ $FastText.Paste() })
        $xpopup.Items.Add($Paste)

        $SelectAll = new-object System.Windows.Forms.ToolStripMenuItem
        $SelectAll.text = "Select All"
        $SelectAll.Add_Click({ $FastText.SelectAll() })
        $xpopup.Items.Add($SelectAll)

        $xpSep2 = new-object System.Windows.Forms.ToolStripSeparator
        $xpopup.Items.Add($xpSep2)

        $Find = new-object System.Windows.Forms.ToolStripMenuItem
        $Find.text = "Find"
        $Find.Add_Click({ $FastText.ShowFindDialog() })
        $xpopup.Items.Add($Find)

        $Replace = new-object System.Windows.Forms.ToolStripMenuItem
        $Replace.text = "Replace"
        $Replace.Add_Click({ $FastText.ShowReplaceDialog() })
        $xpopup.Items.Add($Replace)
        #Replace

        $Goto = new-object System.Windows.Forms.ToolStripMenuItem
        $Goto.text = "Go to Line ..."
        $Goto.Add_Click({ $FastText.ShowGotoDialog() })
        $xpopup.Items.Add($Goto)

        $xpSep3 = new-object System.Windows.Forms.ToolStripSeparator
        $xpopup.Items.Add($xpSep3)

        $ExpandAll = new-object System.Windows.Forms.ToolStripMenuItem
        $ExpandAll.text = "Expand All"
        $ExpandAll.Add_Click({ $FastText.ExpandAllFoldingBlocks() })
        $xpopup.Items.Add($ExpandAll)

        $CollapseAll = new-object System.Windows.Forms.ToolStripMenuItem
        $CollapseAll.text = "Collapse All"
        $CollapseAll.Add_Click({ $FastText.CollapseAllFoldingBlocks() })
        $xpopup.Items.Add($CollapseAll)

        $eventForm.ContextMenuStrip = $xpopup

        $Script:refs['ms_Left'].visible = $false
        $Script:refs['ms_Right'].visible = $false
        $Script:refs['ms_Left'].Width = 0

        $eventform.height = $eventform.height * $tscale

        $FastText.SelectedText = "#region Images

#endregion

"


        try {
            $FastText.CollapseFoldingBlock(0)
        }
        catch {}

        $eventForm.Show()

        $Script:refs['tsl_StatusLabel'].add_TextChanged({
		
                if ($Script:refs['tsl_StatusLabel'].text -ne "Current DPIScale: $tscale") {
                    $errT = new-object System.Windows.Forms.Timer
                    $errT.Interval = 10000
                    $errT.Enabled = $True
                    $errT.add_Tick({ $Script:refs['tsl_StatusLabel'].text = "Current DPIScale: $tscale" 
                            $this.Enabled = $false
                            $this.Dispose()
                        })
                }
		
            })

        $Script:refs['tsl_StatusLabel'].text = "Current DPIScale: $tscale - for resize events multiply all location and size modifiers by `$tscale."

        $Script:refs['spt_Right'].splitterdistance = $Script:refs['spt_Right'].splitterdistance * $tscale



        [void]$Script:refs['MainForm'].ShowDialog()
    }
    catch { Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered unexpectedly at ShowDialog." }

    <#
    #region Actions After Form Closed

    try {

    } catch {Update-ErrorLog -ErrorRecord $_ -Message "Exception encountered after Form close."}

    #endregion Actions After Form Closed
    #>
}



#region Start Point of Execution

# Initialize STA Runspace
$rsGUI = [Management.Automation.Runspaces.RunspaceFactory]::CreateRunspace()
$rsGUI.ApartmentState = 'STA'
$rsGUI.ThreadOptions = 'ReuseThread'
$rsGUI.Open()

# Create the PSCommand, Load into Runspace, and BeginInvoke
#$cmdGUI = [Management.Automation.PowerShell]::Create().AddScript($sbGUI).AddParameter('DPI',$args[0])
$cmdGUI = [Management.Automation.PowerShell]::Create().AddScript($sbGUI).AddParameters(@{'BaseDir' = $PSScriptRoot; 'DPI' = $args[0] })
$cmdGUI.RunSpace = $rsGUI
$handleGUI = $cmdGUI.BeginInvoke()

# Hide Console Window
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();

[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);

		[DllImport("user32.dll")]
		public static extern int SendMessage(int hWnd, int hMsg, int wParam, int lParam);
'

[Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 0) | out-null




#Loop Until GUI Closure
while ( $handleGUI.IsCompleted -eq $false ) { Start-Sleep -Seconds 5 }

# Dispose of GUI Runspace/Command
$cmdGUI.EndInvoke($handleGUI)
$cmdGUI.Dispose()
$rsGUI.Dispose()

Exit

#endregion Start Point of Execution
