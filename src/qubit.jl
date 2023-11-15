### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ 73bded8d-e7de-457d-b2de-7f6402390a5a
using Pkg

# ╔═╡ 45fd7b61-4ad8-4d08-889b-de1fa0c355de
Pkg.add(url="https://github.com/RustyBamboo/Pulses.jl")

# ╔═╡ a040b396-8363-11ee-01de-1fcff0e31c12
using LinearAlgebra, GLMakie, Colors

# ╔═╡ ef179332-814f-4bbc-9cbf-6b62fe8a9a93
using Pulses

# ╔═╡ 366a36cf-8c40-418b-8804-15c19322e496
resolution = (1000,1000)

# ╔═╡ 9f07f43f-0f5d-4389-bef1-e83107551173
function bloch_arrow(θ, ϕ)
    x = sin(2θ) * cos(ϕ)
    y = sin(2θ) * sin(ϕ)
    z = cos(2θ)
    return (x, y, z)
end

# ╔═╡ 47d8bc3f-a746-41ad-b792-c041433a1d39
function bloch_coords(r)
    x = real(r[2, 1] + r[1, 2])
    y = imag(r[2, 1] - r[1, 2])
    z = real(r[2, 2] - r[1, 1])
    return [x, y, -z]
end

# ╔═╡ 69f55be6-ebf3-4ccb-878f-6392f735704d
function bloch_arrow(st)
    global_phase = exp(im * angle(st[1]))
    st = st ./ global_phase
    θ = acos(real(st[1])) # st[1] is real
    ϕ = iszero(θ) ? zero(θ) : angle(st[2] / sin(θ))
    return bloch_arrow(θ, ϕ)
end

# ╔═╡ 1621be8f-fa30-4376-9d4b-08b3a553d038
function plot_arrow!(scene, r; kwargs...)
    x, y, z = bloch_arrow(r)
    # lines!(scene, [0.0, x], [0.0, y], [0.0, z]; kwargs...)
	arrows!(scene, [Point3f([0, 0, 0.])], [Point3f([x,y,z])]; kwargs...)

    return scene
end

# ╔═╡ 9aa8d0b3-6ce1-4ee6-b514-a9be15c51f2f
function plot_arrow_density!(scene, r; kwargs...)
    x, y, z = bloch_coords(r)
    # lines!(scene, [0.0, x], [0.0, y], [0.0, z]; kwargs...)
	arrows!(scene, [Point3f([0, 0, 0.])], [Point3f([x,y,z])]; kwargs...)

    return scene
end

# ╔═╡ ba192167-248c-4ca4-9820-b58f1dc61cf7
function bloch_sphere!(scene)
    wireframe!(scene, GLMakie.Sphere(Point3f(0), 1), color=:black, linewidth=0.1, thickness = 0.6f0, transparency = true)

	wirecolor_outline=RGBA(1.0, 1.0, 1.0, 0.8)

    text!(scene, [Point3f(1.15, 0.0, 0.0)], text="|+⟩", align=(:center, :center), fontsize=20, color=:black)
    text!(scene, [Point3f(0.0, -1.15, 0.0)], text="|i⟩", align=(:center, :center), fontsize=20, color=:black)
    text!(scene, [Point3f(0.0, 0.0, 1.15)], text="|0⟩", align=(:center, :center), fontsize=20, color=:black)
	text!(scene, [Point3f(0.0, 0.0, -1.15)], text="|1⟩", align=(:center, :center), fontsize=20, color=:black)
	    # text!(ax, 1.2, 0.0, 0.0, "|+⟩", textsize = 16, color = :black)
    # text!(ax, -1.2, 0.0, 0.0, "|-⟩", textsize = 16, color = :black)
    # text!(ax, 0.0, 1.2, 0.0, "|i⟩", textsize = 16, color = :black)
    # text!(ax, 0.0, -1.2, 0.0, "|-i⟩", textsize = 16, color = :black)
    # text!(ax, 0.0, 0.0, 1.2, "|0⟩", textsize = 16, color = :black)
    # text!(ax, 0.0, 0.0, -1.2, "|1⟩", textsize = 16, color = :black)
    # CairoMakie.save("out.svg", fig, pt_per_unit=0.5)
	r = 1
    arrows!(scene, [Point3f([0., 0., 0.])], [Point3f([1., 0,0])], arrowsize=0.02)
	arrows!(scene, [Point3f([0., 0., 0.])], [Point3f([0., -1,0])], arrowsize=0.02)
	arrows!(scene, [Point3f([0., 0., 0.])], [Point3f([0., 0,1.])], arrowsize=0.02)

    return scene
end


# ╔═╡ 30b6eb70-21f0-459a-b93c-32d3373d9182
function plot_points!(scene, rhos::Vector{Matrix{ComplexF64}}; kwargs...)
    out = [bloch_coords(r) for r in rhos]
    x = getindex.(out, 1)
    y = getindex.(out, 2)
    z = getindex.(out, 3)
    scatter!(scene, x, y, z, color=1:length(out), colormap=:plasma, markersize=10)
    # lines!(scene, [0.0, x], [0.0, y], [0.0, z]; kwargs...)
    return scene
end

# ╔═╡ f4f110f4-35cf-4a23-92a9-7572821ef47d
function animate_bloch(rhos; name="../images/out.gif")
	size = 1
	fig = Figure(resolution = resolution);
	ax = Axis3(fig[1,1], aspect=(1,1,1), viewmode=:fit, limits = (-size, size, -size, size, -size, size))

	hidedecorations!(ax)  # hides ticks, grid and lables
	hidespines!(ax) 

	ax.xreversed = true

	bloch_sphere!(ax)
	x,y,z = bloch_coords(rhos[1])
	pos = Observable([Point3f(0.0,0.0,0.0)])

	state = Observable([Point3f([x,y,z])])
	arrows!(ax, pos, state, arrowsize=0.05)


	history = Observable(Point3f[])
	push!(history[], Point3f([x,y,z]))

	colors = Observable([0])

    scatter!(ax, history, color=colors, markersize=15)

	



	record(fig, name, 1:length(rhos)) do frame
		x,y,z = bloch_coords(rhos[frame])
		state[] = [Point3f([x,y,z])]
		notify(state)

		push!(history[], Point3f([x,y,z]))
		notify(history)

		push!(colors[], frame)
		notify(colors)	
	end
	# plot_arrow_density!(ax, [1. 0; 0 0im], color=:green, arrowsize=0.05)
	# plot_arrow_density!(ax, [1. 1; 1 1+0im]/2, color=:red, arrowsize=0.05)
end

# ╔═╡ 2b045aa3-545a-456c-a4db-00b2a9ff273e
md"""
## Qubit Evolution
"""

# ╔═╡ f7a64031-d677-4539-9b32-919bf9d7dcd5
begin
	H_0 = [0. 0. 0.;
	       0. 0. 0.;
	       0. 0. -1.]
	
	# Control Hamiltonians       
	X = [0. 1. 0.;
	     1. 0. sqrt(2);
	     0 sqrt(2) 0]
	
	Y = [0. 1im 0.;
	     -1im 0. 1im*sqrt(2);
	      0 -1im*sqrt(2) 0]
	      
	# Desired Unitary operator
	target = [1. 1. 0;
	          1. -1 0;
	          0im 0 sqrt(2)
	          ] / sqrt(2)
	
	# Define our system using drift and control Hamiltonians
	system = Pulses.System(H_0, [X, Y])
	
	# Define a time scale
	t_r = LinRange(0, 10, 100)
	Δt = t_r[2] - t_r[1]
	
	# Define an initial pulse
	x = LinRange(-3, 3, 100)
	inital_pulse = 1e-3.*[exp.(-x.^2) exp.(-x.^2)]
	
	# Solve for an optimal pulse
	sol = Pulses.find_pulse(target, system, Δt, inital_pulse)
end

# ╔═╡ b5182891-c927-4606-a15f-e66d43094dd3
md"""

## Plot Bloch sphere evolution

"""

# ╔═╡ 8fe59314-024c-43a1-b557-c1023fb9dde1
begin
	H = Pulses.hamiltonian(system, sol)
	evolution = Pulses.solve_state_history(H, Δt, [1; 0im; 0.])
end

# ╔═╡ ce4b1ba4-eda6-41c2-a732-d22a2ea29b4e
rhos = [e[begin:2] * e[begin:2]' for e in evolution]

# ╔═╡ 5bc73db3-7fac-4ea7-b1bc-899fea566022
for i in 1:10
	push!(rhos, rhos[end])
end

# ╔═╡ 1ba7bfb0-8984-43a2-80af-489c5384c53a
animate_bloch(rhos; name="../images/qubit_rot.gif")

# ╔═╡ 4edbacb9-2030-4716-b513-9e37a89ae4d0
evolution_2 = Pulses.solve_state_history(H, Δt, [0im; 1; 0.])

# ╔═╡ 36438a59-2874-4ec6-87ce-d2f1ea5fd22d
rhos_2 = [e[begin:2] * e[begin:2]' for e in evolution_2]

# ╔═╡ 14f19a09-1f55-46b0-87e9-e4f2de11f33c
for i in 1:10
	push!(rhos_2, rhos_2[end])
end

# ╔═╡ a7a59d54-4b09-41c1-9f5e-5585bef9ae1c
animate_bloch(rhos_2; name="../images/qubit_rot_1.gif")

# ╔═╡ b483195d-9ba2-42bd-b550-ac90bfbad081
animate_bloch(0.9*rhos .+ 0.1*rhos_2; name="../images/qubit_rot_both.gif")

# ╔═╡ dc8701b4-c9f3-4898-a2cc-25088e6892de
begin
A = [rand(2,2) for _ in 1:length(H)]
A = A .* transpose.(A)

H_r = [Matrix{Float64}(I(3)) for _ in 1:length(H)]
for i in 1:length(H)
	H_r[i][begin:2, begin:2] = A[i]
end
H_r = H .+ 0.5 * H_r
end

# ╔═╡ f8d24a95-f1b5-4203-9916-b06a681f1a41
begin
evolution_r = Pulses.solve_state_history(H_r, Δt, [1; 0im; 0.])
rhos_r = [e[begin:2] * e[begin:2]' for e in evolution_r]
animate_bloch(rhos_r; name="../images/qubit_rot_pert.gif")
end

# ╔═╡ 69e00951-1313-4013-b788-62cd7d7639e3
rhos_decoherence = [((1-i/length(rhos)) * rhos[i] + i/length(rhos) * I(2)) for i in 1:length(rhos)]

# ╔═╡ 66664976-48a4-4fee-aec3-25a364a3bc16
animate_bloch(rhos_decoherence; name="../images/qubit_rot_decoherence.gif")

# ╔═╡ 13feba3b-8a08-4717-bff7-775ea25eff80
md"""

## Plot pulse

"""

# ╔═╡ 777c6927-1b90-4e74-879e-ab23fb242b80
function animate_pulse(t_r, sol, H; name="../images/pulse.gif")
	# fig = Figure(resolution = resolution);
	fig = Figure(resolution = (2000,600));
	ax = Axis(fig[1,1], width = 1000, height = 400, title="Pulse", xlabel="Time [ns]", ylabel="Amplitude", titlesize=40, xlabelsize=30, ylabelsize=30)
	ax2 = Axis(fig[1,2], yreversed=true, aspect=1, title="Hamiltonian", titlesize=40)
	hidedecorations!(ax2)  # hides ticks, grid and lables
	hidespines!(ax2)

	s = 0.7
	ax3 = Axis3(fig[1,3], aspect=(1,1,1), viewmode=:fit, limits = (-s, s, -s, s, -s, s), height=500)
	hidedecorations!(ax3)
	hidespines!(ax3)
	ax3.xreversed = true

	evolution = Pulses.solve_state_history(H, Δt, [1; 0im; 0.])
	rhos = [e[begin:2] * e[begin:2]' for e in evolution]

	bloch_sphere!(ax3)
	x,y,z = bloch_coords(rhos[1])
	pos_bloch = Observable([Point3f(0.0,0.0,0.0)])
	state = Observable([Point3f([x,y,z])])
	arrows!(ax3, pos_bloch, state, arrowsize=0.05)
	history = Observable(Point3f[])
	push!(history[], Point3f([x,y,z]))
	colors = Observable([0])
    scatter!(ax3, history, color=colors, markersize=15)

	

	lines!(ax, t_r, sol[:,1], label=[L"\alpha_0"])
	lines!(ax, t_r, sol[:,2], label=[L"\alpha_1"])

	line = Observable([t_r[1]])
	pos = Observable([0])
	vlines!(ax, line, color=:black)
	vspan!(ax, pos, line, color=:black, alpha=:0.2, label=:none)

	current_H = Observable(abs2.(H[1]))
	heatmap!(ax2, current_H)





	record(fig, name, 1:size(sol,1)) do frame
		line[] = [t_r[frame]]
		notify(line)

		current_H[] = abs2.(H[frame])
		notify(current_H)

		x,y,z = bloch_coords(rhos[frame])
		state[] = [Point3f([x,y,z])]
		notify(state)

		push!(history[], Point3f([x,y,z]))
		notify(history)

		push!(colors[], frame)
		notify(colors)	
	end
		
	return fig
end



# ╔═╡ 36b2c33e-d4b3-4938-aa53-12adebd5b025
animate_pulse(t_r, sol, H)

# ╔═╡ 523cf7cc-16f7-474e-b217-b92924f8d6e8


# ╔═╡ 76fd146c-1425-4829-a3b9-d678c1fea8b7


# ╔═╡ Cell order:
# ╠═a040b396-8363-11ee-01de-1fcff0e31c12
# ╠═73bded8d-e7de-457d-b2de-7f6402390a5a
# ╠═45fd7b61-4ad8-4d08-889b-de1fa0c355de
# ╠═ef179332-814f-4bbc-9cbf-6b62fe8a9a93
# ╠═366a36cf-8c40-418b-8804-15c19322e496
# ╠═9f07f43f-0f5d-4389-bef1-e83107551173
# ╠═47d8bc3f-a746-41ad-b792-c041433a1d39
# ╠═69f55be6-ebf3-4ccb-878f-6392f735704d
# ╠═1621be8f-fa30-4376-9d4b-08b3a553d038
# ╠═9aa8d0b3-6ce1-4ee6-b514-a9be15c51f2f
# ╠═ba192167-248c-4ca4-9820-b58f1dc61cf7
# ╠═30b6eb70-21f0-459a-b93c-32d3373d9182
# ╠═f4f110f4-35cf-4a23-92a9-7572821ef47d
# ╟─2b045aa3-545a-456c-a4db-00b2a9ff273e
# ╠═f7a64031-d677-4539-9b32-919bf9d7dcd5
# ╟─b5182891-c927-4606-a15f-e66d43094dd3
# ╠═8fe59314-024c-43a1-b557-c1023fb9dde1
# ╠═ce4b1ba4-eda6-41c2-a732-d22a2ea29b4e
# ╠═5bc73db3-7fac-4ea7-b1bc-899fea566022
# ╠═1ba7bfb0-8984-43a2-80af-489c5384c53a
# ╠═4edbacb9-2030-4716-b513-9e37a89ae4d0
# ╠═36438a59-2874-4ec6-87ce-d2f1ea5fd22d
# ╠═14f19a09-1f55-46b0-87e9-e4f2de11f33c
# ╠═a7a59d54-4b09-41c1-9f5e-5585bef9ae1c
# ╠═b483195d-9ba2-42bd-b550-ac90bfbad081
# ╠═dc8701b4-c9f3-4898-a2cc-25088e6892de
# ╠═f8d24a95-f1b5-4203-9916-b06a681f1a41
# ╠═69e00951-1313-4013-b788-62cd7d7639e3
# ╠═66664976-48a4-4fee-aec3-25a364a3bc16
# ╟─13feba3b-8a08-4717-bff7-775ea25eff80
# ╠═777c6927-1b90-4e74-879e-ab23fb242b80
# ╠═36b2c33e-d4b3-4938-aa53-12adebd5b025
# ╠═523cf7cc-16f7-474e-b217-b92924f8d6e8
# ╠═76fd146c-1425-4829-a3b9-d678c1fea8b7
