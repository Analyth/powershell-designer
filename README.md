# Powershell-Designer
A free "Windows Forms" Designer for PowerShell.

# The interface

![image](https://user-images.githubusercontent.com/106910381/227701209-2671d6ef-5f3c-45cd-85bb-2d51f1237529.png)

# Why this fork
This fork has been created to avoid the following error when saving a form with '**save**' or '**save as**' command.

## The Error
Here is the error I encountered:
```
Cannot convert value "800;600" to type "System.Int32". Error: "Input string was not in a correct format." At line:252 char:33 + ... $n[0] = [math]::Round(($n[0] / 1) * $tscale) + ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  + CategoryInfo : InvalidArgument: (:) [], RuntimeException  + FullyQualifiedErrorId : InvalidCastFromStringToInteger
```

## Explanations

When the application starts, it uses the culture on your computer. The application uses the 'list separator' in the code.
The default culture is 'en-US' with the list separator ',' (comma). If the culture used for your language does not use a ',' (comma) as a list separator the application will generate some errors.

To avoid this problem, the easiest way is to run the application with the 'en-US' culture by forcing the PowerShell session that starts the application to run with the 'en-US' culture
instead of the one on your computer (i.e. fr-CH culture uses the list separator ';' (semicolon).

## Tips

You can see your list separator on your Windows by going to: Settings/Time & language/Language & region/Administrative language settings and then click on "Additional settings...".
You also can call the Window by using the command 'intl.cpl' 😉

![image](https://user-images.githubusercontent.com/106910381/227702520-14b4aca7-f08e-4ed5-99bc-3200db7ca487.png)

You also can check your 'list separator' by using the PowerShell command:
``` PowerShell
(Get-Culture).Textinfo.ListSeparator
```

Enjoy to use this app!
