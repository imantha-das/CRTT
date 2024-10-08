import pynetlogo

netlogo = pynetlogo.NetLogoLink(gui = False)
# Please change to location of model
model_path = "/Users/imantha/workspace/CRTT/test_munkres.nlogo"
netlogo.load_model(model_path)

netlogo.command("setup")
netlogo.command("go")

netlogo.kill_workspace()