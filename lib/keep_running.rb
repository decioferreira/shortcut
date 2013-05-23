require 'java'

import javax.swing.SwingUtilities

# http://stackoverflow.com/questions/10108822/jruby-script-with-rubeus-and-swing-exiting-once-packaged-into-jar-using-warble
# Warbler calls System.exit() after your main script exits. This causes the Swing EventThread to exit, closing your app.
# https://github.com/jruby/warbler/blob/master/ext/JarMain.java#L131
event_thread = nil
SwingUtilities.invokeAndWait { event_thread = java.lang.Thread.currentThread }
event_thread.join
