@tool
class_name PreviewPositioner
extends VBoxContainer

@onready var rotate_r_button : Button = %RotateRight
@onready var rotate_l_button : Button = %RotateLeft

@onready var z_up_button : Button = %UpZButton
@onready var z_down_button : Button = %DownZButton
@onready var x_up_button : Button = %UpXButton
@onready var x_down_button : Button = %DownXButton

@onready var y_up_button : Button = %UpYButton
@onready var y_down_button : Button = %DownYButton

@onready var cancel_button : Button = %CancelButton
@onready var confirm_button : Button = %ConfirmButton
