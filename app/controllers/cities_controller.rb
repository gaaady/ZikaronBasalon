class CitiesController < ApplicationController
  respond_to :json

  def autocomplete_city
    sub_params = JSON.parse(params.first.second)
    q = sub_params['q']
    country_id = sub_params['country_id']
    manager_meta = current_user&.meta_id
    results = City.normalized
    results = results.normalized_search(q, country_id, current_user.email == 'zikaronbasalonglobal@gmail.com')

    if sub_params['witness_search'].nil?
      if manager_meta.present?
        if current_user.simple_admin? && !current_user.global_admin?
          communities = CommunityLeadership.where(manager_id: current_user.meta.id)
          community_city_ids = communities.map(&:city_id)
          if communities.size > 0
            results = results.where(id: community_city_ids)
          end
        end
      end
    end
    results.first(12)
    if q.present?
      city_name = City.not_on_the_list_names.detect { |name| name.upcase.include?(q.upcase) }
      not_on_the_list_city = City.find_by(name: city_name) if city_name
      results.unshift(not_on_the_list_city) if not_on_the_list_city
    end
   render json: results
  end

  def autocomplete_country
     q = params[:q]
     results = Country.normalized_search(q).first(12)
     render json: results
  end

  def show
  end

  def safe_params
    params.require(:city).permit(:country_id, :q)
  end
end
