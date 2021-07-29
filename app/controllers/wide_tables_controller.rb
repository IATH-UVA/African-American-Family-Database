class WideTablesController < ApplicationController
  before_filter :authenticate_user!
  
  active_scaffold :wide_table do |conf|
  end
  
  def search_tables
    @tables = SrcTable.find :all
    @carts = []
    @groups = current_user.collection_groups
    # .each do |g|
    #   @carts += g.collections
    # end
  end

  def adv_search_tables
    # @tables = SrcTable.find :all
    # @carts = []
    # @groups = current_user.collection_groups
    # @fields = ['first_name','last_name', 'owner','race','gender','birth_year','record_year']
    # @operators = ['=','>=', '<=', 'includes']
    # @boolean = ['and', 'or']
    # # .each do |g|
    # #   @carts += g.collections
    # # end
    render :layout => false
  end
  
  def basic_search
    render :layout => false
  end
  
  def adv_search
    size = params['field'].size
    sql = ''
    vals = []
    # (0..size-1).each do |x|
    params['field'].keys.each do |k|
      @x = k
      # debugger
      if params['value'][k] != nil and params['value'][k] != ''
        if params['boolean'] != nil and params['boolean'][k] != ''
          sql += " #{params['boolean'][k]} "
        end
        f = params['field'][k]
        o = params['operator'][k]
        v = params['value'][k]
        if o == 'includes'
          o = 'like'
          v = "%#{v}%"
        end
        sql += "(#{f} #{o} ?)"
        vals << v
        @sql = sql
        # debugger 
      end
    end
    if params[:tables] != nil
      r_str = ''
      s_str = ''
      params[:tables].each do |table|
        s_str += ' or ' if s_str != ''
        s_str += 'src_table_id = ?'
        vals << table
        r_str += ', ' if r_str != ''
        r_str += "#{table}"
      end
      sql += ' and ' if sql != ''
      sql += "(#{s_str})"
    end
    
    # debugger
    @wide_tables = WideTable.find(:all, :conditions => [sql]+vals)
        # if @wide_tables were an AR::Relation object, we could end preceding line:  .page(params[:page]).per( params['perpage'] )
        # instead @wide_tables.class == Array, so must instead add next line:
    @wide_tables = Kaminari.paginate_array(@wide_tables).page(params[:page]).per( params['perpage'] )
    
    puts sql
    # debugger
    respond_to do |format| 
      format.js do
      end
    end    
  end
  
  def find_results
    str = ''
    values = []
    @search_terms = ''
    @error_message = ''

=begin
    if params[:first_name] != nil and params[:first_name] != ''
      str += ' and ' if str != ''
      if params[:use_soundex] == '1'
        str += 'first_name sounds like ?'
      else
        str += 'first_name like ?'
      end
      values << "%#{params[:first_name]}%"
      @search_terms += ', ' if @search_terms != ''
      @search_terms += "First name = #{params[:first_name]}"
    end
    if params[:last_name] != nil and params[:last_name] != ''
      str += ' and ' if str != ''
      if params[:use_soundex] == '1'
        str += 'last_name sounds like ?'
      else
        str += 'last_name like ?'
      end
      values << "%#{params[:last_name]}%"
      @search_terms += ', ' if @search_terms != ''
      @search_terms += "Last name = #{params[:last_name]}"
    end
    if params[:owner_purchaser_etc] != nil and params[:owner_purchaser_etc] != ''
      str += ' and ' if str != ''
      if params[:use_soundex] == '1'
        str += 'owner sounds like ?'
      else
        str += 'owner like ?'
      end
      values << "%#{params[:owner_purchaser_etc]}%"
      @search_terms += ', ' if @search_terms != ''
      @search_terms += "owner, purchaser, etc = #{params[:owner_purchaser_etc]}"
    end
    if params[:mother] != nil and params[:mother] != ''
      str += ' and ' if str != ''
      if params[:use_soundex] == '1'
        str += 'mother sounds like ?'
      else
        str += 'mother like ?'
      end
      values << "%#{params[:mother]}%"
      @search_terms += ', ' if @search_terms != ''
      @search_terms += "mother = #{params[:mother]}"
    end
=end

    # these were previously single params w/o second (relation selector) params and optional third params (for range end).
    # relation was constant 'contains', but is now variable with selector second param.

    str = stringFieldSubcontroller(str, values, 'first_name', params[:first_name], params[:first_name_end], params[:first_name_op], 'First name')
    str = stringFieldSubcontroller(str, values, 'last_name', params[:last_name], params[:last_name_end], params[:last_name_op], 'Last name')
    str = stringFieldSubcontroller(str, values, 'owner', params[:owner_purchaser_etc], params[:owner_end], params[:owner_op], 'owner, purchaser, etc')
    str = stringFieldSubcontroller(str, values, 'mother', params[:mother], params[:mother_end], params[:mother_op], 'mother')

=begin
    if params[:birth_year] != nil and params[:birth_year] != ''
      start = params[:birth_year].to_i
      stop = start
      if params[:birth_year_range] != nil and params[:birth_year_range] != ''
        start -= params[:birth_year_range].to_i
        stop += params[:birth_year_range].to_i
        @search_terms += ', ' if @search_terms != ''
        @search_terms += "Birth year = #{params[:birth_year]} +/-#{params[:birth_year_range]} years"
      else
        @search_terms += ', ' if @search_terms != ''
        @search_terms += "Birth year = #{start}"
      end
      str += ' and ' if str != ''
      str += 'birth_year >= ? and birth_year <= ?'
      values += [start,stop]
    end
    if params[:record_year] != nil and params[:record_year] != ''
      start = params[:record_year].to_i
      stop = start
      if params[:record_year_end] != nil and params[:record_year_end] != ''
        stop += params[:record_year_end].to_i
        @search_terms += ', ' if @search_terms != ''
        @search_terms += "Record years = #{params[:record_year]}-#{params[:record_year_end]}"
      else
        @search_terms += ', ' if @search_terms != ''
        @search_terms += "Record year = #{start}"
      end
      str += ' and ' if str != ''
      str += 'record_year >= ? and record_year <= ?'
      values += [start,stop]
    end
=end

    # these were previously double params w the second param (for range end) sometimes unused.
    # the semantics of the second param when used was different for the two uses.
    # new formatting makes them consistent for the user and similar to the name fields.

    str = intFieldSubcontroller(str, values, 'birth_year', params[:birth_year], params[:birth_year_end], params[:birth_year_op], 'Birth year')
    str = intFieldSubcontroller(str, values, 'record_year', params[:record_year], params[:record_year_end], params[:record_year_op], 'Record year')

    if params[:race] != nil
      r_str = ''
      s_str = ''
      params[:race].each do |race|
        s_str += ' or ' if s_str != ''
        s_str += 'race like ?'
        values << "%#{race}%"
        r_str += ', ' if r_str != ''
        r_str += race
      end
      str += ' and ' if str != ''
      str += "(#{s_str})"
      @search_terms += ', ' if @search_terms != ''
      @search_terms += "race = #{r_str}"
    end
    if params[:gender] != nil
      r_str = ''
      s_str = ''
      params[:gender].each do |gender|
        s_str += ' or ' if s_str != ''
        s_str += 'gender like ?'
        values << "#{gender}"
        r_str += ', ' if r_str != ''
        r_str += gender
      end
      str += ' and ' if str != ''
      str += "(#{s_str})"
      @search_terms += ', ' if @search_terms != ''
      @search_terms += "gender = #{r_str}"
    end
    if params[:tables] != nil
      r_str = ''
      s_str = ''
      params[:tables].each do |table|
        s_str += ' or ' if s_str != ''
        s_str += 'src_table_id = ?'
        values << table
        r_str += ', ' if r_str != ''
        r_str += "#{table}"
      end
      str += ' and ' if str != ''
      str += "(#{s_str})"
      @search_terms += ', ' if @search_terms != ''
      @search_terms += "Source table = #{r_str}"
    end

    if defined?(params[:search_terms_op]) && params[:search_terms_op] == 'freetext' && defined?(params[:search_terms])
        search_terms_error_message = verify_search_terms(params[:search_terms])
        @error_message += search_terms_error_message
        if @error_message == ''
          str = str + ' and ' if str != ''
          str = str + ' ( '
          str = str + params[:search_terms]
          str = str + ' )'
        end
    end

    conditions = [str] + values

    if defined?(params[:results_order_op]) && params[:results_order_op] == 'freetext' && defined?(params[:results_order])
      results_order_error_message = verify_results_order(params[:results_order])
      @error_message += results_order_error_message
    end

    if @error_message == ''
      if defined?(params[:results_order_op]) && params[:results_order_op] == 'freetext' && defined?(params[:results_order])
        @wide_tables = WideTable.reorder(params[:results_order]).find(:all, :conditions => conditions)
      else
        @wide_tables = WideTable.find(:all, :conditions => conditions)
      end
        # if @wide_tables were an AR::Relation object, we could end preceding lines:  .page(params[:page]).per( params['perpage'] ) . . .
      @nResultsTotal = @wide_tables.length
        # . . . instead @wide_tables.class == Array, so must instead add next line:
      @wide_tables = Kaminari.paginate_array(@wide_tables).page(params[:page]).per( params['perpage'] )
    end

    # render :update do |page|
    #   # page.replace 'search_results', 'results'
    # end
    # render :text => 'lllll'
    respond_to do |format| 
      format.js do
        # render(:result_list) do |page|
        #   page.replace_html 'search_results', '========='
        # end
      end
    end
  end

  def show_result
    @wide_table = WideTable.find(params[:id])
    @source = SrcTable.find(@wide_table.src_table_id)
    respond_to do |format| 
      format.js do
      end
    end
  end

  def update_results
    order = ''
    if params[:field] == 'household'
      order = 'src_table_row_num asc'
    end
    @value = [params[:field], params[:id]]
    @wide_tables = WideTable.find(:all, :conditions => ["#{params[:field]} = ?", params[:id]], :order => order)
        # if @wide_tables were an AR::Relation object, we could end preceding line:  .page(params[:page]).per( params['perpage'] )
        # instead @wide_tables.class == Array, so must instead add next line:
    @wide_tables = Kaminari.paginate_array(@wide_tables).page(params[:page]).per( params['perpage'] )
    @search_terms = "#{params[:field].humanize}: #{params[:id]}"
    respond_to do |format| 
      format.js do
      end
    end    
  end

  def show_next
    order = ''
    if params[:field] == 'household'
      order = 'src_table_row_num asc'
    end
    @value = [params[:field], params[:id]]
    @wide_tables = WideTable.find(:all, :conditions => ["#{params[:field]} = ?", params[:id]], :order => order)
        # if @wide_tables were an AR::Relation object, we could end preceding line:  .page(params[:page]).per( params['perpage'] )
        # instead @wide_tables.class == Array, so must instead add next line:
    @wide_tables = Kaminari.paginate_array(@wide_tables).page(params[:page]).per( params['perpage'] )
    @search_terms = "#{params[:field].humanize}: #{params[:id]}"
    respond_to do |format| 
      format.js do
      end
    end    
  end
  
  def add_to_cart
    order = ''
    y = HypItem.new
    y.wide_table_id = params[:id]
    y.hyp_field = params[:field]
    y.hyp_value = params[:value]
    y.save
    @cart = HypItem.find :all
    respond_to do |format| 
      format.js do
      end
    end    
  end

  def remove_hyp
    order = ''
    y = HypItem.find(params[:id])
    id = y.collection.id
    y.destroy
    collection = Collection.find id
    @hyp_name = collection.name
    @hyp_id = collection.id
    @cart = collection.hyp_items
    respond_to do |format| 
      format.js do
      end
    end    
  end

  def view_hyp
    order = ''
    @wide_table = WideTable.find params[:id]
    @source = SrcTable.find(@wide_table.src_table_id)
    respond_to do |format| 
      format.js do
      end
    end    
  end

  def add_to_group
    @group = nil
    if (params[:group] == nil or params[:group] == '') and (params[:new_group] == nil or params[:new_group] == '')
      render :js => "$('#name_error').html('Must supply a name!')"
    else
      if (params[:group] != nil and params[:group] != '')
        @group = CollectionGroup.find params[:group]
      else
        @group = CollectionGroup.create(:name => params[:new_group])
        current_user.collection_groups << @group
      end
    end
    respond_to do |format| 
      format.js do
      end
    end    
  end
  
  def add_to_collection
    @hyp_name = ''
    collection = nil
    if (params[:hypothesis] == nil or params[:hypothesis] == '') and (params[:new_hypothesis] == nil or params[:new_hypothesis] == '')
      render :js => "$('#name_error').html('Must supply a name!')"
    else
      if params[:hypothesis] != nil and params[:hypothesis] != ''
        collection = Collection.find(params[:hypothesis])
        @hyp_name = collection.name
      else
        collection = Collection.new
        collection.name = params[:new_hypothesis]
        @hyp_name = params[:new_hypothesis]
        collection.group_id = params[:group_id]
        collection.save
        
      end
      if params[:result_ids] != nil and params[:result_ids] != ''
        params[:result_ids].split(',').each do |id|
          factoid = HypItem.new
          factoid.wide_table_id = id.to_i
          factoid.hyp_field = params[:field_name]
          factoid.hyp_value = params[:field_value]
          factoid.save
          collection.hyp_items << factoid
        end
      else
        factoid = HypItem.new
        factoid.wide_table_id = params[:src_table]
        factoid.hyp_field = params[:field_name]
        factoid.hyp_value = params[:field_value]
        # factoid.collection = collection
        factoid.save
        collection.hyp_items << factoid
      end
      @hyp_id = collection.id
      @cart = collection.hyp_items
      @group_name = "#{collection.collection_group.name}"
      @group_id = collection.collection_group.id
      @validated = collection.validated
      respond_to do |format| 
        format.js do
        end
      end    
    end
    
  end
  
  def remove_hypothesis
    c = Collection.find(params[:id])
    c.hyp_items.each {|h| h.destroy}
    c.destroy
    respond_to do |format| 
      format.js do
      end
    end    
  end

  def remove_group
    g = CollectionGroup.find(params[:id])
    g.collections.each do |c|
      c.hyp_items.each {|h| h.destroy}
      c.destroy
    end
    g.destroy
    respond_to do |format| 
      format.js do
      end
    end    
  end
  
  def final_facts
    @collections = Collection.find :all
  end
  
  def print_group
    group = CollectionGroup.find params[:id]
    @name = group.name
    @collections = group.collections
    render :action => 'final_facts'
  end
  
  def validate_collection
    c = Collection.find params[:id]
    c.validated = true
    c.save
    render :text => ''
  end
  def invalidate_collection
    c = Collection.find params[:id]
    c.validated = false
    c.save
    render :text => ''
  end
  
  def update_comments
    # debugger
    @wide_table = WideTable.find params[:id]
    c = @wide_table.comments.find(:first, :conditions => "user_id = #{current_user.id}")
    if c == nil
      c = Comment.new
      c.user = current_user
      c.wide_table = @wide_table
    end
    c.comment = params[:comments].strip
    c.save
    render :file => 'wide_tables/_show_comments.js.erb'
  end

def stringFieldSubcontroller(str, values, fieldname, operand1, operand2, operator, engFieldname)
  case operator
  when 'range'
    if (operand1 != '' || operand2 != '')
      @search_terms += ', ' if @search_terms != ''
      @search_terms += "#{engFieldname} between #{operand1} and #{operand2}"
      str += ' and ' if str != ''
      str += '('

      if operand1 != '' && operand2 != ''
        str += "#{fieldname} between ? and ?"
        values << operand1
        values << operand2 
      elsif operand1 != ''
        str += "#{fieldname} >= ?"
        values << operand1 
      elsif operand2 != ''
        str += "#{fieldname} <= ?"
        values << operand2 
      # else assert or fail
      end

      str += ')'
    end

  else
  if operand1 != '' # so any other operator w data supplied
    @search_terms += ', ' if @search_terms != ''
    @search_terms += "#{engFieldname} #{operator} = #{operand1}"
    str += ' and ' if str != ''

    case operator
    when 'fragment'
      operand1 = "%#{operand1}%"
    when 'begins'
      operand1 = "#{operand1}%"
    when 'ends'
      operand1 = "%#{operand1}"
    #already ok:  'equals', 'like', 'rlike', 'soundslike'
    end

    case operator
    when 'fragment', 'begins', 'ends' 
      operator = 'like'
    when 'equals'
      operator = '='
    when 'soundslike'
      operator = 'sounds like'
    #already ok:  'like', 'rlike'
    end

    str += "#{fieldname} #{operator} ?"
    values << operand1
  end
  end

  return str
end

def intFieldSubcontroller(str, values, fieldname, operand1, operand2, operator, engFieldname)
  case operator
  when 'range'
    if (operand1 != '' || operand2 != '')
      @search_terms += ', ' if @search_terms != ''
      @search_terms += "#{engFieldname} between #{operand1} and #{operand2}"
      str += ' and ' if str != ''
      str += '('

      if operand1 != '' && operand2 != ''
        str += "#{fieldname} between ? and ?"
        values << operand1.to_i
        values << operand2.to_i 
      elsif operand1 != ''
        str += "#{fieldname} >= ?"
        values << operand1.to_i 
      elsif operand2 != ''
        str += "#{fieldname} <= ?"
        values << operand2.to_i 
      # else assert or fail
      end

      str += ')'
    end
  when 'equals'
  if operand1 != '' # so any other operator w data supplied
    @search_terms += ', ' if @search_terms != ''
    @search_terms += "#{engFieldname} #{operator} = #{operand1}"
    str += ' and ' if str != ''

    operator = '='

    str += "#{fieldname} #{operator} ?"
    values << operand1.to_i
  end
  end

  return str
end


def verify_search_terms(search_terms)
  return ''
end 

def verify_results_order(results_order)
  errors = 0
  error_message0 = ''
  error_message1 = ''
  parts = results_order.split(',')
  sep = '';
  parts.each do |part|
    part.strip!
    pieces = part.split(/\s+/)
    case pieces.length
    when 1,2
      case pieces[0]
      when 'src_table_row_num','src_table_id','record_year','first_name','last_name','birth_year','race','gender','owner','location_person','mother','father','topic_type','topic_ord','topic_title','age','birthplace','household','family_role','marital_status','occupation','dwelling','ability_to_write','ability_to_read','status','minister','family','record_date','husband','wife','record','school','division','value','birth_month','disposition','purchaser','legatee','deaf','value_notes','age_group','comments'
        error_message1 += sep + ' ' + pieces[0]
      else
        errors = errors + 1
        error_message0 += "\n" + errors.to_s + ': expecting one of these:  src_table_row_num,src_table_id,record_year,first_name,last_name,birth_year,race,gender,owner,location_person,mother,father,topic_type,topic_ord,topic_title,age,birthplace,household,family_role,marital_status,occupation,dwelling,ability_to_write,ability_to_read,status,minister,family,record_date,husband,wife,record,school,division,value,birth_month,disposition,purchaser,legatee,deaf,value_notes,age_group,comments'
        error_message1 += sep + ' ' + errors.to_s + '^ ' + pieces[0]
      end
      case pieces.length
      when 2
        case pieces[1]
        when 'asc', 'desc'
          error_message1 += ' ' + pieces[1]
        else
          errors = errors + 1
          error_message0 += "\n" + errors.to_s + ': expecting nothing or one of these:  asc,desc'
          error_message1 += sep + ' ' + errors.to_s + '^ ' + pieces[1]
        end
      end
    else
      errors = errors + 1
      error_message0 += "\n" + errors.to_s + ': misc error'
      error_message0 += sep + ' ' + errors.to_s + '^ ' + part
    end
    sep = ',' 
  end
  if errors == 0
    return ''
  else
    return error_message1 + "\n" + error_message0
  end
end

end 
