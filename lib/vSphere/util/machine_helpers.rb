module VagrantPlugins
  module VSphere
    module Util
      module MachineHelpers
        def wait_for_ssh(env)
          if !env[:machine].config.vm.communicator.nil? && env[:machine].config.vm.communicator == :winrm
            env[:ui].info(I18n.t('vsphere.waiting_for_winrm'))
          else
            env[:ui].info(I18n.t('vsphere.waiting_for_ssh'))
          end

          loop do
            break if env[:machine].communicate.ready?
            sleep 5
          end
        end
      end
    end
  end
end
