% startup_lab3  (SCRIPT, run from the Lab3 model PreLoadFcn)
% logging rate for the USB-UART link (<=460800 baud): 200 Hz default (1 kHz only if stable).

disp('Lab3 ready - Hall log. Open template for DIM dsPIC33AK512MC510, add Hall inputs for log. solution in Lab3_HallLog_hw_solution (template-based, deploy).');

url = ['https://mplab-blockset.github.io/MPLAB-Device-Blocks-for-Simulink/tools/dim_viewer/#dim=dsPIC33AK512MC510&bb=MCLV&sort=function&grp=1&alt=0&mc=1'];
fprintf('  Board pinout link: <a href="matlab:java.awt.Desktop.getDesktop().browse(java.net.URI(''%s''))">%s</a>\n', url, url);
