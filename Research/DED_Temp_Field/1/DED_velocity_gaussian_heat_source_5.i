[Mesh]
  [./DED_clad]
    type = FileMeshGenerator
    file = DED_Temp_Field_Test_5_Mesh_1.e
  []

  # [gen]
  #   type = GeneratedMeshGenerator
  #   dim = 3
  #   xmin = 0
  #   xmax = 1
  #   ymin = 0
  #   ymax = 0.5
  #   zmin = 0
  #   zmax = 0.1
  #   nx = 10
  #   ny = 5
  #   nz = 1
  # []
[]

[Variables]
  [temp]
  []
[]

[ICs]
  [temp_substrate]
    type = ConstantIC
    variable = temp
    value = 300
  []
[]

[Kernels]
  [time]
    type = ADHeatConductionTimeDerivative
    variable = temp
  []
  [heat_conduct]
    type = ADHeatConduction
    variable = temp
    thermal_conductivity = thermal_conductivity
  []
  [heatsource]
    type = ADMatHeatSource
    material_property = volumetric_heat
    variable = temp
    scalar = 1
  []
[]

[BCs]
  # Convection 
  [Convection_top]
    type = ConvectiveFluxFunction
    variable = temp
    boundary = SideSet_top
    T_infinity = 300.0
    coefficient = 10.0 #This will behave as described in the header of this file if this evaluates to 10
  []

  # Radiative Heat Flux

  # Neumann BC -> No Flux

  # [temp_bottom_fix]
  #   type = ADDirichletBC
  #   variable = temp
  #   boundary = SideSet_bottom_substrate
  #   value = 300
  # []
  
  # [temp_otherfaces]
  #   type = ADDirichletBC
  #   variable = temp
  #   boundary = NodeSet_otherfaces
  #   value = 300
  # []
[]

[Materials]
  [volumetric_heat]
    type = ADVelocityGaussianHeatSource
    r = 370e-3   # 0.2   # effective radii (mm) 370e-3 
    power = 300000    # 0.3   # laser power (1e-3 W) 300000
    efficiency = 0.3
    factor = 2
    y0 = 0      # 0.25  0
    z0 = 0.001      # 0.1  300e-6  0.001
    function_vx =  8.47e-3    #  0.05    # 8.47e-03 # laser velocity in m/s = mm/ms
    heat_source_type = 'mixed'
    threshold_length = 0.1
  []
  [density]
    type = ADGenericConstantMaterial
    prop_names = 'density'
    prop_values = 7609e-9
  []
  [heat]
    type = ADHeatConductionMaterial
    specific_heat_temperature_function = 500
    thermal_conductivity_temperature_function = 25e-6
    temp = temp
  []
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient

  automatic_scaling = true

  solve_type = 'PJFNK'

  petsc_options_iname = '-ksp_type -pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'preonly lu       superlu_dist'

  line_search = 'none'

  l_max_its = 20
  nl_max_its = 10
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-8

  start_time = 0.0
  end_time = 0.5   # 20
  dt = 0.01  # 1
  dtmin = 1e-4
[]

[Outputs]
  csv = true
  exodus = true             # Added to visualize
  file_base = DED_Temp_Field_MALAMUTE_5_WB_BC2_Convective
[]

[Postprocessors]
  [avg_temp]
    type = ElementAverageValue
    variable = temp
  []
  [max_temp]
    type = ElementExtremeValue
    variable = temp
    value_type = max
  []
  [min_temp]
    type = ElementExtremeValue
    variable = temp
    value_type = min
  []
[]
