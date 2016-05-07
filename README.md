# Realtime-Metal

Check out the processKernel() function in VideoProcessor.swift
It's sort of commented and should give you an idea of how my wrapper classes are used,
as long as you're at least slightly familiar with the way Metal works.

Note the index I'm setting each resource to, and the buffer(i)s in the kernel function.
Data loaded into index:1 will be passed to the kernel as buffer(1).

The Kernels.metal file holds my metal kernels, but kernels will still be loaded if
they're in a different .metal source file.
