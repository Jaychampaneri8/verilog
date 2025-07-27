`timescale 10ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.07.2025 15:28:27
// Design Name: 
// Module Name: Washing_machine
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module Washing_machine(clk , reset , door_close , start , filled , det_added , cycle_timeout , drained , spin_timeout ,
        door_lock , motor_on , fill_valve_on , drain_valve_on , soap_wash , water_wash , done);
        
    input clk , reset , door_close , start , filled , det_added , cycle_timeout , drained , spin_timeout;
    output reg door_lock , motor_on , fill_valve_on , drain_valve_on , soap_wash , water_wash ,done;

    parameter ideal = 3'b000;
    parameter fill_water = 3'b001;
    parameter add_detergent = 3'b010;
    parameter cycle = 3'b011;
    parameter drain_water = 3'b100;
    parameter spin = 3'b101;
    
    reg[2:0] current_state,next_state;
    reg soap_done,water_done;
    
    always@(current_state or start or door_close or filled or det_added or drained or cycle_timeout or spin_timeout)
    begin
        case(current_state)
        ideal:
            if((start == 1) && (door_close == 1))//this block will execute when door is closed and machine is started
            begin
                next_state = fill_water;
                door_lock = 1;
                motor_on = 0;
                fill_valve_on = 0;
                drain_valve_on = 0;
                soap_wash = 0;
                water_wash = 0;
                done = 0;
            end 
            else //this block will run when machine is started but door is not shut properly
            begin
                next_state = current_state;
                door_lock = 0;
                motor_on = 0;
                fill_valve_on = 0;
                drain_valve_on = 0;
                soap_wash = 0;
                water_wash = 0;
                done = 0; 
            end 
        fill_water:
            if(filled == 1)
                begin//enters this "if" if the water is filled 
                     if(soap_done == 1)//enters this "if" if the soap_wash is done means if the clothes are soaked
                        begin 
                            next_state = cycle;
                            door_lock = 1;
                            motor_on = 1;
                            fill_valve_on = 0;
                            drain_valve_on = 0;
                            soap_wash = 0;
                            water_wash = 0;
                            done = 0;
                        end
                     else //this block will run if the clothes are not soaked
                        begin
                            next_state = add_detergent;
                            door_lock = 1;
                            motor_on = 0;
                            fill_valve_on = 0;
                            drain_valve_on = 0;
                            soap_wash = 0;
                            water_wash = 0;
                            done = 0;   
                        end  
                end
            else//this block will execute when the water is not filled 
                begin
                    next_state = current_state;
                    door_lock = 1;
                    motor_on = 0;
                    fill_valve_on = 1;
                    drain_valve_on = 0;
                    soap_wash = 0;
                    water_wash = 0;
                    done = 0; 
                end
            add_detergent:
                if(det_added ==1)//this block will execute when detergent is added for soap wash
                    begin
                        next_state = cycle;
                        door_lock = 1;
                        motor_on = 0;
                        fill_valve_on = 0;
                        drain_valve_on = 0;
                        soap_wash = 1;
                        water_wash = 0;
                        done = 0;
                    end
                else //this block will execute when detergent is not added yet and will wait to be added
                    begin 
                         next_state = current_state;
                         door_lock = 1;
                         motor_on = 0;
                         fill_valve_on = 0;
                         drain_valve_on = 0;
                         soap_wash = 0;
                         water_wash = 0;
                         done = 0;
                    end  
            cycle:
                if(cycle_timeout == 1)//this block will execute when cycle is not timed out
                    begin
                        next_state = drain_water;
                        door_lock = 1;
                        motor_on = 0;
                        fill_valve_on = 0;
                        drain_valve_on = 0;
                        done = 0;
                    end
                else //this block will execute after cycle time out happens 
                    begin
                        next_state = current_state;
                        door_lock = 1;
                        motor_on = 1;
                        fill_valve_on = 0;
                        drain_valve_on = 0;
                        done = 0;  
                    end
            drain_water:
                if (drained == 1)//this block will execute when water is drained 
                    begin
                        if(water_done == 1)//this block will execute when water is drained and clothes are soaked
                            begin
                                next_state = spin;
                                door_lock = 1;
                                motor_on = 0;
                                fill_valve_on = 0;
                                drain_valve_on = 1;
                                soap_wash = 1;
                                water_wash = 1;
                                done = 0;   
                            end 
                        else if (soap_done == 1)//this block will execute when water wash is done for drying
                            begin
                                next_state = fill_water;
                                door_lock = 1;
                                motor_on = 0;
                                fill_valve_on = 0;
                                drain_valve_on = 0; 
                                soap_wash = 1;
                                done = 0;
                            end      
                    end
                else //this will continuously check the drain valve to complete draine is done
                    begin 
                        next_state = current_state;
                        door_lock = 1;
                        motor_on = 0;
                        fill_valve_on = 0;
                        drain_valve_on = 1; 
                        done = 0;
                    end 
            spin:
                if(spin_timeout == 1)//this block will execute when the drying is done by spinning and the whole process will be completed
                    begin
                        next_state = ideal;
                        door_lock = 0;
                        motor_on = 0;
                        fill_valve_on = 0;
                        drain_valve_on = 0;
                        done = 1; 
                    end  
                else//this block will execute when the spin time out is not active 
                    begin   
                        next_state = current_state;
                        door_lock = 1;
                        motor_on = 1;
                        fill_valve_on = 0;
                        drain_valve_on = 0;
                        done = 0;
                    end  
            default:
                begin
                    next_state = ideal;
                    door_lock = 0;
                    motor_on = 0;
                    fill_valve_on = 0;
                    drain_valve_on = 0;
                    water_wash =0;
                    soap_wash = 0;
                    done = 0; 
                end  
           endcase                                      
    end 
always @(posedge clk or posedge reset) begin
    if (reset)
        current_state <= ideal;
    else
        current_state <= next_state;
end 

always @(posedge clk or posedge reset)
begin
    if (reset)
        soap_done <= 0;
    else if (current_state == add_detergent && det_added)
        soap_done <= 1;
    else if (current_state == spin && spin_timeout)
        soap_done <= 0;
end 

always @(posedge clk or posedge reset)
begin
    if (reset)
        water_done <= 0;
    else if (current_state == fill_water && soap_done && filled)
        water_done <= 1; // Indicates rinse cycle has started
    else if (current_state == spin && spin_timeout)
        water_done <= 0; // Reset after process ends
end
endmodule
