extends FKVariableSignals
class_name FKEditorVariableSignals

## Emitted after the variable editor modal applies its edits (renames, additions,
## removals) to a sheet's variables. Things that show variable names listen for this.
signal variables_edited
