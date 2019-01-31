# Copyright 2019 Eugene Berta
# Licensed under the MIT license

require 'sketchup.rb'

module CommunityExtensions
  module Lsystem
    class LSystem
      
      class Step

        attr_reader :eff_x
        attr_reader :eff_y

        attr_reader :eff_x_width
        attr_reader :eff_y_width
	
	attr_reader :length
	attr_reader :width
	attr_reader :angle
	attr_reader :mult
        
        def initialize(length, width, angle)
          @length = length
          @width = width
          @angle = angle
          @eff_x = nil
          @eff_y = nil
          @eff_x_width = nil
          @eff_y_width = nil

	  @mult = 1.0

          self.calc_effs()



        end


        #get effective X,Y step
        def calc_effs
          @eff_x = (Math.cos(@angle*(Math::PI/180.0))*@length).round(2)
          @eff_y = (Math.sin(@angle*(Math::PI/180.0))*@length).round(2)

          @eff_x_width = (Math.cos((@angle-90.0)*(Math::PI/180.0))*(@width/2.0)).round(2)
          @eff_y_width = (Math.sin((@angle-90.0)*(Math::PI/180.0))*(@width/2.0)).round(2)

          #print("EZB eff #{@eff_x},#{eff_y}  widths #{@eff_x_width},#{@eff_y_width}\n")
        end

        def add_angle(angle)
          @angle += angle
          self.calc_effs()
        end

        def mult_length(length_mult)
          @length *= length_mult

          @width *= length_mult
          
	  @mult *= length_mult
	  
          self.calc_effs()
        end
        
      end

      class LPoint

        attr_reader :xpos, :ypos
        
        def initialize(xpos, ypos)
          @xpos = xpos
          @ypos = ypos
        end

        def add_step(step)
          @xpos += step.eff_x
          @ypos += step.eff_y
	  @xpos = @xpos.round(2)
	  @ypos = @ypos.round(2)
        end
        
      end
      
      class Rule

        attr_reader :name
        
        def initialize(rule, grammer, probabilities=nil)
          @name = rule
          @grammer = grammer
          @probabilities = nil

          if not probabilities.nil?
            @probabilities = Array.new()
            prev_value = 0
            next_value = 0
            
            probabilities.each { |i|
              i = Float(i)
              next_value = prev_value + i
              @probabilities.push(next_value)
              prev_value = next_value
            }
          end
        end
        
        def get_rule()
          if @probabilities.nil?
            return @grammer
          end

          counter = 0
          random_rule = rand()
          while random_rule > @probabilities[counter]
            counter += 1
          end

          #print("EZB counter: #{counter}\n")
          
          return @grammer[counter]
          
        end
      end

      def initialize(angle, axiom, rules=nil)
        @angle = angle
        @axiom = axiom
        if rules.nil?
          @rules = Array.new()
        end
        @alphabet = nil
	
	#@faces = Set.new()
	
      end

      def add_rule(rule, grammer, probabilities=nil)
        new_rule = Rule.new(rule, grammer, probabilities)
        @rules.push(new_rule)
      end

      def add_rule_user(input)
        if input == ""
          return
        end
        input = input.strip
        sinput = input.split(' ')
        fpos = 0
        had_float = false
        sinput.each { |i|
          begin
            Float(i)
            had_float = true
            break
          rescue
            fpos += 1
          end
        }

        if had_float
          self.add_rule(sinput[0], sinput[1..fpos-1], sinput[fpos..-1])
        else
          if sinput.length < 2
	     sinput.push(" ")
	  end	
          self.add_rule(sinput[0], sinput[1])
        end
        
      end
      
      def generate_alphabet(iterations, limit_size)
        @alphabet = @axiom

        temp = nil

        #loop through iterations
        iterations.times do |i|
          temp = ''
          #loop through letters
          @alphabet.each_char { |w|
            @rules.each { |k|
              if k.name == w
                w = k.get_rule()
              end
            }
            temp += w
          }

          @alphabet = temp

          if @alphabet.length > limit_size
            msg = "L-System: Alphabet #{@alphabet.length} bigger then #{limit_size}, limiting iterations to #{i+1}\n"
            print(msg)
            notify =  UI::Notification.new(self, msg, nil, nil)
            notify.show
            break
          end
          
          #print("EZB: #{i}\n")
        end
        #print("EZB alpha: #{@alphabet}\n")
      end

      def forward_line(group, curr_point, step)

        #depth = 100
        #width = 100
        #pts = []
        #pts[0] = [0, 0, 0]
        #pts[1] = [width, 0, 0]
        #pts[2] = [width, depth, 0]
        #pts[3] = [0, depth, 0]
        # Add the face to the entities in the model
        #face = entities.add_face(pts)

        
        from_point = curr_point.dup
        curr_point.add_step(step)
        #print("EZB line (#{from_point.xpos}, #{from_point.ypos})  (#{curr_point.xpos}, #{curr_point.ypos})\n")
        #print("EZB rect (#{from_point.xpos-step.eff_x_width}, #{from_point.ypos-step.eff_y_width})\
        #(#{curr_point.xpos-step.eff_x_width}, #{curr_point.ypos-step.eff_y_width}})\
        #(#{curr_point.xpos+step.eff_x_width}, #{curr_point.ypos+step.eff_y_width})\
        #(#{from_point.xpos+step.eff_x_width}, #{from_point.ypos+step.eff_y_width})\n")

	scale = Geom::Transformation.scaling(step.mult, step.mult, 1.0)
	point = Geom::Point3d.new(from_point.xpos, from_point.ypos, 0)
	trans = Geom::Transformation.translation(point)
	#print("EZB mult #{step.mult}\n")
	rotate = Geom::Transformation.rotation(Geom::Point3d.new(0,0,0), Geom::Vector3d.new(0, 0, 1), step.angle.degrees) 
	#Sketchup.active_model.active_entities.add_instance(@comp_def, trans*rotate*scale)
        group.entities.add_instance(@comp_def, trans*rotate*scale)
	
      end
      
      def run(iterations, line_length, line_width, line_modification, limit_size)
        self.generate_alphabet(iterations, limit_size)
        step = Step.new(line_length, line_width, 0.0)

	from_point = LPoint.new(0,0)
	curr_point = LPoint.new(0,0)
	curr_point.add_step(step)
        pts = []
        pts[0] = [from_point.xpos-step.eff_x_width, from_point.ypos-step.eff_y_width, 0]
        pts[1] = [curr_point.xpos-step.eff_x_width, curr_point.ypos-step.eff_y_width, 0]
        pts[2] = [curr_point.xpos+step.eff_x_width, curr_point.ypos+step.eff_y_width, 0]
        pts[3] = [from_point.xpos+step.eff_x_width, from_point.ypos+step.eff_y_width, 0]
        # Add the face to the entities in the model
        Sketchup.active_model.start_operation('L-System Run', true)
        
        bgroup = Sketchup.active_model.entities.add_group
        #face = Sketchup.active_model.active_entities.add_face(pts)
        face = bgroup.entities.add_face(pts)
        face.pushpull(1.0, true)
        comp_inst = bgroup.to_component
        @comp_def = comp_inst.definition
        #@faces.add(face)
        
        #face.pushpull(1.0, true)
        Sketchup.active_model.active_entities.erase_entities(comp_inst)
        
        curr_point = LPoint.new(0,0)

        fgroup = Sketchup.active_model.entities.add_group
        
        branches = Array.new()

        @alphabet.each_char { |w|
          case w
          when 'F'    #Move forward and draw line
            forward_line(fgroup, curr_point, step)
            
          when 'f'    #Move forward without drawing a line
            curr_point.add_step(step)

          when '+'    #Change angle counter clockwise
            step.add_angle(360.0/@angle)
            
          when '-'    #Change angle clockwise
            step.add_angle(-360.0/@angle)
            
          when '|'    #Turn around
            step.add_angle(180.0)

          when '<'    #Mult line length
            step.mult_length(line_modification)

          when '>'    #Divide line length
            step.mult_length(1.0/line_modification)

          when '['    #Adds another branch
            branches.push([curr_point.dup, step.dup])

          when ']'    #Returns to the parent branch
            goto_branch = branches.pop
            curr_point = goto_branch[0]
            step = goto_branch[1]
            
          end
          
        }

        Sketchup.active_model.commit_operation
      end
      
    end

    @@defaults = [14, 4, 6, 1, 0.95, 30000, "F", "F F[+F]F[-F]F" ]
    
    def self.run_lsystem
      prompts = ["Circle Angle Splits", "Iters", "Length", "Width", "Multiplier", "Alpha Limit", "Axiom", "Rule1", "Rule2", "Rule3", "Rule4", "Rule5", "Rule6", "Rule7", "Rule8"]
      #defaults = [14, 4, 6, 1, 0.95, 30000, "F", "F F[+F]F[-F]F" ]
      #defaults = [16, 5, 6, 1, 0.95, 30000, "F", "F F[+F][-F]F F[-F]F F[+F]F 0.5 0.3 0.2"]
      input = UI.inputbox(prompts, @@defaults, "Specify L-System Parameters")

      @@defaults = input.dup

      lsystem = LSystem.new(Integer(input[0]), input[6])
      lsystem.add_rule_user(input[7])
      lsystem.add_rule_user(input[8])
      lsystem.add_rule_user(input[9])
      lsystem.add_rule_user(input[10])
      lsystem.add_rule_user(input[11])
      lsystem.add_rule_user(input[12])
      lsystem.add_rule_user(input[13])
      lsystem.add_rule_user(input[14])
      lsystem.run(Integer(input[1]), Float(input[2]), Float(input[3]), Float(input[4]), Float(input[5]))

    end

    unless file_loaded?(__FILE__)
      menu = UI.menu('Plugins')
      menu.add_item('Run L-System') {
        self.run_lsystem
      }
      file_loaded(__FILE__)
    end


  end # module Lsystem
end # module CommunityExtensions
