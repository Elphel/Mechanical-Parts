# Mechanical Parts
Mechanical CAD files

#Work
* When a part is ready for manufacturing manually save it to <i>production/</i> in the following formats:
 * <b>\*.stp</b> - STEP
 * <b>\*.igs</b> - IGES
 * <b>\*.dxf</b> - DXF
 * <b>\*.dwb</b> - DWB
 * <b>\*.pdf</b> - 2D drawing
 * <b>\*.bmp</b> - some view/screenshot from the CAD program 

<b>NOTE: DO NOT ADD THESE FILES TO REPOSITORY</b>
* On <i>git push</i> a hook will upload files to the server
* The pattern for publishing on [wiki.elphel.com]:

> === PARTNUMBER - DESCRIPTION ===<br/>
> SOME OR NO INFO<br/>
> {{Cad4a\|PARTNUMBER}}<br/>
> \-\-\-\-

#Setup
##<i>pre-push</i> hook
###about
* Archive all <i>\*.stp, \*.igs, \*.dxf, \*.dwb</i>
* Add info to the meta header of all <i>\*.pdf</i>
* Crop all <i>\*.bmp</i> and convert them into jpeg.
* Back up all of the files into <i>production/uploaded/</i> to prevent repeating the above actions
* Upload results to a file server ([community.elphel.com])

The hook runs at every <i>git push</i> even if there are no changes
###requirements
* imagemagick

###enable
* Copy <i>githooks/pre-push</i> into <i>.git/hooks/</i>
* Edit <i>.git/hooks/pre-push</i> - set <i>remote_dir</i> to a proper one.
* If the private ssh key name is not default, add -e to rsync line:
> rsync -e 'ssh -i /home/user/.ssh/key' -a -f '- /*/' . $remote_dir
* Make <i>.git/hooks/pre-push</i> executable

[community.elphel.com]:http://community.elphel.com/files/production/
[wiki.elphel.com]:http://wiki.elphel.com
