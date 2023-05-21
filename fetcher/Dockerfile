FROM public.ecr.aws/lambda/ruby:3.2

COPY Gemfile ./
ENV GEM_HOME=${LAMBDA_TASK_ROOT}
RUN bundle config set --local path 'vendor/bundle'
RUN bundle install

COPY *.rb ./

# Command can be overwritten by providing a different command in the template directly.
CMD ["app.lambda_handler"]
