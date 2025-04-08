#!/system/bin/xbin/busybox sh
echo "######### File=Property.sh $(date) #########" >>"${ServiceLog}"
#bg
Key=config.max_starting_bg
Value=8
setprop $Key $Value
echo $Key:$(getprop $Key)

#GPU UI
Key=ro.fps_enable
Value=1
setprop $Key $Value
echo $Key:$(getprop $Key)

Key=gpu.fps
Value=auto
setprop $Key $Value
echo $Key:$(getprop $Key)

Key=cpu.fps
Value=auto
setprop $Key $Value
echo $Key:$(getprop $Key)


Key=boot.fps
Value=30
setprop $Key $Value
echo $Key:$(getprop $Key)

Key=hw2d.force
Value=1
setprop $Key $Value
echo $Key:$(getprop $Key)

Key=hw3d.force
Value=1
setprop $Key $Value
echo $Key:$(getprop $Key)

Key=debug.hwui.render_dirty_regions
Value=false
setprop $Key $Value
echo $Key:$(getprop $Key)

Key=persist.splitwindow.support_all
Value=true
setprop $Key $Value
echo $Key:$(getprop $Key)

Key=transition_animation_scale
Value=0.6
setprop $Key $Value
echo $Key:$(getprop $Key)

Key=persist.sys.scrollingcache
Value=4
setprop $Key $Value
echo $Key:$(getprop $Key)

Key=sys.use_fifo_ui
Value=1
setprop $Key $Value
echo $Key:$(getprop $Key)

Key=view.scroll_friction
Value=10
setprop $Key $Value
echo $Key:$(getprop $Key)

Key=debug.performance.tuning
Value=1
setprop $Key $Value
echo $Key:$(getprop $Key)


Key=debug.sf.hw
Value=1
setprop $Key $Value
echo $Key:$(getprop $Key)

Key=debug.egl.hw
Value=1
setprop $Key $Value
echo $Key:$(getprop $Key)

Key=debug.gr.swapinterval
Value=0
setprop $Key $Value
echo $Key:$(getprop $Key)

Key=hwui.disable_vsync
Value=true
setprop $Key $Value
echo $Key:$(getprop $Key)

Key=persist.sys.ui.hw
Value=1
setprop $Key $Value
echo $Key:$(getprop $Key)

Key=debug.hwui.renderer
Value=skiavk
setprop $Key $Value
echo $Key:$(getprop $Key)

#Dalvik
Key=dalvik.vm.execution-mode
Value=int:jit
setprop $Key $Value
echo $Key:$(getprop $Key)

Key=dalvik.vm.startheapsize
Value=1k
setprop $Key $Value
echo $Key:$(getprop $Key)

Key=dalvik.vm.dexopt-flags
Value=v=n,o=v
setprop $Key $Value
echo $Key:$(getprop $Key)

Key=dalvik.vm.verify-bytecode
Value=false
setprop $Key $Value
echo $Key:$(getprop $Key)

#kill mem
Key=persist.sys.purgeable_assets
Value=1
setprop $Key $Value
echo $Key:$(getprop $Key)

#multi sim
Key=persist.vendor.radio.multisim.config
Value=dsds
setprop $Key $Value
echo $Key:$(getprop $Key)

#Power Manager
Key=pm.sleep_mode
Value=1
setprop $Key $Value
echo $Key:$(getprop $Key)
