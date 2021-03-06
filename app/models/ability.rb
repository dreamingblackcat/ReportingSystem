class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)
    if(user.admin?)
      can :manage,User
      can :manage,Report
      can :manage,Team
      can :manage,TeamReport
      cannot :submit,Report,{:status => 'submitted'}
      can :manage,Adminmail
      cannot :submit,Report do|report|
        !report.submittable?
      end
    elsif(user.member?)
      can :read,User,{:id => user.id}
      can :read,Team
      can :index,Report,{:user_id => user.id}
      can :read, Report do|report|
        report.user_id === user.id
      end
      can :submit,Report,{:user_id => user.id }
      cannot :submit,Report,{:status => 'submitted'}
      cannot :submit,Report,{:status => 'reviewed'}
      cannot :submit,Report do|report|
        !report.submittable?
      end
      can [:edit,:update],Report,{:user_id => user.id}
      cannot :update,Report do|report|
        report.user_id != user.id
      end
      can :create,Report
    elsif(user.leader?)
      team_id = user.team_id
      can :read,User
      can :read, Team
      can :read,Report
      can :review,Report do|report|
        report.try(:user).try(:team) == user.team
      end
      cannot :review,Report,{:status => 'reviewed'}
      can :submit,Report,{:user_id => user.id }
      cannot :submit,Report,{:status => 'submitted'}
      cannot :submit,Report do|report|
        !report.submittable?
      end
      can :create,Report,{:user_id => user.id}
      can :update,Report do|report|
         report.try(:user).try(:team) == user.team
      end
      can :manage, TeamReport,:team =>{:users => {:id => user.id}}
    else
    end

  end
end
