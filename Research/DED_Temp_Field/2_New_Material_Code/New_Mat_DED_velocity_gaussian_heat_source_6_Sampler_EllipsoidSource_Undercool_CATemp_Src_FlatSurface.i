[Mesh]
  # [DED_clad]
  #   type = FileMeshGenerator
  #   file = DED_Temp_Field_Test_6_Mesh_1.e
  # []

  [gen]
    type = GeneratedMeshGenerator
    dim = 3
    xmin = 0
    xmax = 0.0240  # 1    0.004   0.0100
    ymin = 0
    ymax = 0.0200  # 0.5  0.002   0.0200   # Need to change the laser path function_y accordingly
    zmin = 0
    zmax = 0.0100  # 0.1  0.001   0.0100   # Need to change the laser path function_z accordingly
    nx = 80    # 100    # 10  20   200
    ny = 80     # 80    # 5   10   100
    nz = 40     # 50    # 1   10   100
  []
[]

[Variables]
  [temp]
  []
  # [current_Temp]
  #   family = LAGRANGE
  #   order = FIRST
  # []
  # [Undercooling]
  #   family = LAGRANGE
  #   order = FIRST
  # []
  # [Dendrite_Growth_Rate]
  #   family = LAGRANGE
  #   order = FIRST
  # []
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
    # save_in = current_Temp        # Save the variable to an AuxVariable
  []
[]

[BCs]
  # # Dirichlet BC on top (Testing only, not very reasonable)
  # [Dirichlet_top_test]
  #   type = DirichletBC
  #   boundary = 3  # SideSet_top,  In 3D, back = 0, bottom = 1, right = 2, top = 3, left = 4, front = 5
  #   value = 300
  #   variable = temp
  # []

  # Convective Heat Flux
  [convection_top_1] # currently in use
    type = ConvectiveFluxFunction
    variable = temp
    boundary = 3  # SideSet_top,  In 3D, back = 0, bottom = 1, right = 2, top = 3, left = 4, front = 5
    T_infinity = 300.0
    coefficient = 300.0 # 20.0 1e5 # 10  300
    # Natural convection, 5 ~ 25 W/(m^2 * K). Forced convection: 20 ~ 300 W/(m^2 * K)
  []

  # # [convection_top_2]
  # #   type = ConvectiveHeatFluxBC
  # #   variable = temp
  # #   boundary = SideSet_top
  # #   T_infinity = 300.0
  # #   heat_transfer_coefficient = 10.0
  # # []

  # # [convection_top_3]
  # #   type = ConvectionHeatTransferBC
  # #   variable = temp
  # #   boundary = SideSet_top
  # #   htc_ambient = 10
  # #   T_ambient = 300
  # # []

  # Radiative Heat Flux
  [radiation_top_1] # currently in use
    type = FunctionRadiativeBC
    variable = temp
    boundary = 3  # SideSet_top,  In 3D, back = 0, bottom = 1, right = 2, top = 3, left = 4, front = 5
    # htc/(stefan-boltzmann*4*T_inf^3)
    emissivity_function = 0.2 # '3/(5.670367e-8*4*300*300*300)'    0.20   0.8  # stefan boltzmann constant = 5.670367e-8 W/m^2K^4
    # Using previous default
    Tinfinity = 300
  []

  # # [radiation_top_2]
  # #   type = RadiativeHeatFluxBC
  # #   variable = temp
  # #   boundary = SideSet_top
  # #   Tinfinity = 300    # 1500
  # #   boundary_emissivity = 0.2   # 0.3
  # #   view_factor = 0.5
  # # []

  # # Neumann BC -> No Flux

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
  # [volumetric_heat]
  #   type = ADVelocityGaussianHeatSource
  #   r = 370e-3   # 0.2   # effective radii (mm) 370e-3
  #   power = 300000    # 0.3   # laser power (1e-3 W) 300000
  #   efficiency = 0.3
  #   factor = 2
  #   y0 = 0      # 0.25  0
  #   z0 = 0.001      # 0.1  300e-6  0.001
  #   function_vx =  8.47e-3    #  0.05    # 8.47e-03 # laser velocity in m/s = mm/ms
  #   heat_source_type = 'mixed'
  #   threshold_length = 0.1
  # []

  [volumetric_heat]
    type = FunctionPathEllipsoidHeatSource
    rx = 0.000375 # 0.000375
    ry = 0.000375 # 0.000375
    rz = 0.000375 # 0.000375
    power = 350 # 300 60 65  300 250 350
    efficiency = 0.3 # 0.3
    factor = 0.9 # 2.0 1.0 0.5 1.5 0.8 0.9
    function_x = path_x
    function_y = path_y
    function_z = path_z
  []

  [density]
    type = ADGenericConstantMaterial
    prop_names = 'density'
    prop_values = 7609 # kg/m^3
  []
  [heat]
    type = ADHeatConductionMaterial
    specific_heat_temperature_function = 500 #  J/kg·K
    thermal_conductivity_temperature_function = 25 # W/m·K
    temp = temp
  []

  [Undercooling_M]
    type = DerivativeParsedMaterial
    property_name = undercooling_pn
    coupled_variables = 'temp'
    constant_names = 'T_m'
    constant_expressions = '1620'
    expression = "T_m - temp"
    outputs = exodus
  []
  [Dendrite_Growth_Rate_M]
    type = DerivativeParsedMaterial
    property_name = dendrite_growth_rate_pn
    coupled_variables = 'temp'
    constant_names = 'T_m Avel nvel'
    constant_expressions = '1620 0.00001 1.00'
    expression = "Avel * (T_m - temp)^(nvel)"
    outputs = exodus
  []

  [solidification_rate]
    type = SolidificationRate
    solidus_temperature = 1531.50
    liquidus_temperature = 1620.00
    temperature = temp
    outputs = exodus
  []
[]

[Functions]
  [path_x]
    type = ParsedFunction
    expression = "10.58e-3*t + 0.01" # 2*cos(2.0*pi*t) 8.47e-3*t  6.35e-3*t  10.58e-3*t
  []
  [path_y]
    type = ParsedFunction
    expression = 0.010 # 2*sin(2.0*pi*t)   0  0.0012  0.0005   # Adjust according to ymax in the mesh block
  []
  [path_z]
    type = ParsedFunction
    expression = 0.010 # 1 0.001 0.0012 0.0008 0.00115        # Adjust according to zmax in the mesh block
  []
[]


[AuxVariables]
  # [current_Temp]
  #   family = LAGRANGE
  #   order = FIRST
  # []
  # [Undercooling]
  #   family = LAGRANGE
  #   order = FIRST
  # []
  # [dendrite_growth_rate]
  #   family = LAGRANGE
  #   order = FIRST
  # []
  [temperature_dt]
    family = MONOMIAL
    order = CONSTANT
  []
[]


[AuxKernels]
  # [undercooling]
  #   type = FunctionAux
  #   variable = current_Temp
  #   function = undercooling
  #   execute_on = 'INITIAL TIMESTEP_BEGIN'
  # []
  # [Dendrite_Growth_Rate]
  #   type = FunctionAux
  #   variable = undercooling
  #   function = Dendrite_Growth_Rate
  #   execute_on = 'INITIAL TIMESTEP_BEGIN'
  # []

  # [current_Temp]
  #   type = FunctionAux
  #   variable = current_Temp
  #   function = current_Temp
  #   execute_on = 'INITIAL TIMESTEP_BEGIN'
  # []

  # [undercooling]
  #   type = FunctionAux
  #   variable = undercooling
  #   function = undercooling
  #   execute_on = 'INITIAL TIMESTEP_BEGIN'
  # []

  # [Dendrite_Growth_Rate]
  #   type = FunctionAux
  #   variable = Dendrite_Growth_Rate
  #   function = Dendrite_Growth_Rate
  #   execute_on = 'INITIAL TIMESTEP_BEGIN'
  # []

  [T_derivative]
    type = TimeDerivativeAux
    variable = temperature_dt
    functor = temp
    factor = 1
    execute_on = 'TIMESTEP_END'
  []

[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
  []
[]

[VectorPostprocessors]
  [point_value_vector_postprocessor_u]
    type = PointValueSamplerCSV
    variable = 'temp temperature_gradient solidification_rate'             #  temperature_gradient solidification_rate          #  only for modified code for reading CSV File     # undercooling_pn dendrite_growth_rate_pn
    samples_file = data_points_CATemp_FlatSurface_2.csv     #  only for modified code for reading CSV File      data_points_test.csv
    column_indices = '0 1 2'                     #  only for modified code for reading CSV File
    # points = '0.002 0.0012 0.006 0.002 0.0012 0.0007  0.002 0.0012 0.008  0.002 0.0012 0.009  0.002 0.0012 0.010'
    # points = '0 0.0012 0.001  0.002 0.0012 0.001  0.004 0.0012 0.001'
    # points = '0.001 0 0 0.002 0 0'
    sort_by = id
    # default_values = '300 0 0'    #  default_values = '300'   # This samples: temp, temperature_gradient, and solidification_rate If only sample temp => '300'
    execute_on = 'initial timestep_end'
  []
[]

[Adaptivity]      # Added to reduce unused elements (Jim Oct. 1, 2025) 
  max_h_level = 5
  initial_marker = 'box'
  initial_steps = 2
  [Markers]
    [box]
      type = BoxMarker
      bottom_left = '0.0090 0.0075 0.0075' # '0 0 0'  '0.0110 0.0090 0.0090'
      top_right = '0.0160 0.0125 0.0120'  # '0.5 1 0'  '0.0140 0.0110 0.0100'
      inside = 'refine'
      outside = 'do_nothing'
    []
  []
[]

[Executioner]
  type = Transient

  automatic_scaling = true

  solve_type = 'NEWTON'

  petsc_options_iname = '-pc_type -pc_hypre_type' # '-ksp_type -pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'hypre boomeramg' # 'preonly lu       superlu_dist'

  line_search = 'none'

  l_max_its = 20
  nl_max_its = 10
  nl_rel_tol = 1e-10 # 1e-6
  nl_abs_tol = 1e-10 # 1e-8

  start_time = 0.0
  end_time = 0.37 # 20  0.5 0.47 (for 8.47e-3) 0.62 (for 6.35e-3) 0.37 (for 10.58e-3)
  dt = 0.01 # 1
  dtmin = 1e-4
[]

[Outputs]
  csv = true
  exodus = true # Added to visualize
  # file_base = 'outputs/CATemp_Source_Flat_Surface/Flat_Surface_3_Set8_350W_v847_factorPoint9_LargerDomainSample_Adaptivity_1/Flat_Surface_3_Set8_350W_v847_factorPoint9_LargerDomainSample_Adaptivity_1_out'
  # file_base = 'outputs/CATemp_Source_Flat_Surface/Flat_Surface_3_Set7_350W_v635_factorPoint9_LargerDomainSample_Adaptivity_1/Flat_Surface_3_Set7_350W_v635_factorPoint9_LargerDomainSample_Adaptivity_1_out'   #  _LargerDomain
  file_base = 'outputs/CATemp_Source_Flat_Surface/Flat_Surface_3_Set9_350W_v1058_factorPoint9_LargerDomainSample_Adaptivity_1/Flat_Surface_3_Set9_350W_v1058_factorPoint9_LargerDomainSample_Adaptivity_1_out'     
  # file_base = 'outputs/G_R_Ratio/Study_Flat_1_300W_BC_factor_Test/Study_Flat_1_300W_BC_factor_Test_out'      
  # file_base = 'outputs/CATemp_Source/Center_Path_7_300W_BC_facto1andHalf_TopDirichlet/Center_Path_7_300W_BC_factor1andHalf_TopDirichlet_out'
  # file_base = 'outputs/CATemp_Source/Center_Path_5_300W_BC_factorHalf_4LargerRangeZ/Center_Path_5_300W_BC_factorHalf_4LargerRangeZ_out'
  # file_base = 'outputs/65W_lowerPath_1/DED_65W_lowerPath_1_out'
  # file_base = DED_Temp_Field_MALAMUTE_5_Sampler_1
  # file_base = DED_Temp_Field_MALAMUTE_6_Sampler_2_Ellipsoid_TestTempField_BC_Set1-1-3_300W_out
  # file_base = DED_Temp_Field_MALAMUTE_6_Sampler_2_Ellipsoid_TestTempField_5Radii_300W_out
  # file_base = DED_Temp_Field_MALAMUTE_6_Sampler_4_Ellipsoid_TestTempField_ChangeSamplingOrigin_Smaller_65W_out
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
  # [memory]
  #   type = MemoryUsage
  #   outputs = 'console'
  # []
[]
