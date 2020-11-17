                                ##############
                                ## dry part ##
                                ##############
# question 1
    the controller of snapping_sheet is implemented with the SnappingSheetController class.
    this controller allows the user to set a listener to events and accordingly set the sheet
    into each of its defined snapping positions. it allows the user to query the current position
    of the sheet and where to move it.

# question 2
   inorder to set an animation to the snapping movement of the snapping sheet we use parameter
   'snappingCurve' when we declare a SnapPosition. this parameter takes an instance from the Curves class
   which allows us to set many different movement animations for our objects' movement.

# question 3
    GestureDetector provides more controls over InkWell such as dragging which is a nice thing to have for your UX
    on the other InkWell include the popular ripple effect , which is also nice for your UX.
    in the end, one is better then the other only in context of what kind of UX you are looking for
    and what suits the app better.



