import nl4py
import os 

# Initialize NL4Py
nl4py.initialize("C://Program Files//NetLogo 6.1.0")

# Path to netlogo and model
netlogo_path = "C://Program Files//NetLogo 6.1.0"
model_path = "model/crtt_v2.nlogo"
gui = True

# Load Model
if gui:
    # Load Model
    n = nl4py.netlogo_app()
    n.open_model(model_path)
else:
    n = nl4py.create_headless_workspace()
    n.open_model(model_path)


# Get parameters
param_names = n.get_param_names() # Identify parameter names
param_rngs = n.get_param_ranges() # Identify parameter values
params = {nm : rng for nm,rng in zip(param_names,param_rngs)}
# print(param_names)
# print(param_rngs)

# Steup and Go commands
n.command("setup")
n.command("repeat 7200 [go]")

# How to save a plot
n.command('export-plot "Queuing" "../results/queuing.csv"')
